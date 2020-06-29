//
//  HomeViewController.swift
//  UenoLab
//
//  Created by UenoLab on 9/11/19.
//  Copyright © 2019 UenoLab. All rights reserved.
//

import UIKit
import Charts
import RealmSwift
struct Cordinate {
    let xAxis: Double
    let yAxis: Double
}

class HomeViewController: BaseViewController {

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var genderTextField: UITextField!
    @IBOutlet weak var jobTextField: UITextField!
    @IBOutlet weak var birthdayTextField: UITextField!
    @IBOutlet weak var memoTextView: UITextView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var chartsView: LineChartView!

    // Store Data that received from bluetooth
    var rawData: [Cordinate] = []
    // Convert to DataType can be used to show on graph
    var lineChartEntries: [ChartDataEntry] = []
    // Store x legend info
    var xAxis = 0.0
    // Timer to update time label
    var timer: Timer?
    // Counter to count seconds
    var counter = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Home"
        setupNaviItem()
        setupDefaultData()
        setupView()
        setupGraphData()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(receiveDataNotification(_:)),
            name: NSNotification.Name.didUpdateBluetoothDataNotificationName,
            object: nil
        )
    }

    @objc func receiveDataNotification(_ notification: Notification) {
        guard let arr = notification.object as? [Int] else { return }
        appendDataToGraph(values: arr)
    }

    private func setupNaviItem() {
        let rightBtn = UIBarButtonItem(image: #imageLiteral(resourceName: "icon_history"), style: .plain, target: self, action: #selector(showHistory))
        navigationItem.rightBarButtonItem = rightBtn
    }

    private func setupDefaultData() {
        birthdayTextField.text = Date().toString(format: "MM/dd/yyyy")
        genderTextField.text = "Male"
    }

    private func setupView() {
        stopButton.isEnabled = false
        chartsView.chartDescription?.enabled = false
        chartsView.noDataText = "No data is available now. Please hit `Start` button"
        chartsView.gridBackgroundColor = NSUIColor.purple
        chartsView.rightAxis.enabled = false
        chartsView.legend.enabled = false
        chartsView.xAxis.enabled = true
        chartsView.xAxis.labelPosition = .bottom
    }

    // MARK: - Graph
    private func setupGraphData() {
        //Prepare Line Data
        for item in rawData {
            let value = ChartDataEntry(x: item.xAxis, y: item.yAxis)
            lineChartEntries.append(value)
        }
        // Setup line appearance
        let set1 = LineChartDataSet(entries: lineChartEntries, label: "Heart beat")
        set1.mode = .cubicBezier
        set1.axisDependency = .left
        set1.colors = [NSUIColor.red]//[NSUIColor(red: CGFloat(255 / 255.0), green: CGFloat(241 / 255.0), blue: CGFloat(46 / 255.0), alpha: 1.0)]
        set1.lineWidth = 1.0
        set1.highlightColor = NSUIColor.red

        // Setup circle apppearance
        set1.drawCirclesEnabled = false
        set1.drawCircleHoleEnabled = false
        set1.drawValuesEnabled = false
        set1.circleRadius = 5.0
        set1.circleColors = [NSUIColor.red]

        // Setup fill area
        set1.drawFilledEnabled = true
        set1.fillAlpha = 0.5
        set1.fillColor = NSUIColor.white
        set1.fillFormatter = DefaultFillFormatter { _, _ -> CGFloat in
            return CGFloat(self.chartsView.leftAxis.axisMinimum)
        }

        let data = LineChartData()
        data.addDataSet(set1)

        chartsView.data = data
    }

    // MARK: - Timer
    private func startTimeCounter() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { (timer) in
            self.updateTime()
        })
    }

    func stopTimer() {
        counter = 0
        timer?.invalidate()
        timer = nil
    }

    func updateTime() {
        self.counter = self.counter + 1
        let hour = self.counter / 3600
        let minute = (self.counter - hour * 3600) / 60
        let second = self.counter % 60
        if hour == 0 {
            self.timeLabel.text = String(format: "%02d:%02d", minute, second)
        } else {
            self.timeLabel.text = String(format: "%02d:%02d:%02d", hour, minute, second)
        }
    }

    func appendDataToGraph(values: [Int]) {
        for item in values {
            xAxis += 1.0 / Double(values.count)
            let newDataEntry = ChartDataEntry(x: xAxis, y: Double(item))
            lineChartEntries.append(newDataEntry)
            rawData.append(Cordinate(xAxis: xAxis, yAxis: Double(item)))
            chartsView.data?.addEntry(newDataEntry, dataSetIndex: 0)
            if rawData.count > 5 {
                chartsView.setVisibleXRange(minXRange: 1.0, maxXRange: 6.0)
            }
            chartsView.notifyDataSetChanged()
            chartsView.moveViewToX(xAxis)
        }

    }

    func storeData() {
        let userRecord = UserRecord()
        userRecord.name = nameTextField.string
        userRecord.job = jobTextField.string
        userRecord.birthday = birthdayTextField.string
        userRecord.gender = genderTextField.string
        userRecord.heartBeat.append(objectsIn: rawData.map({ (val) -> DrawObject in
            let obj = DrawObject()
            obj.yValue = val.yAxis
            obj.xValue = val.xAxis
            return obj
        }))
        userRecord.memo = memoTextView.string
        userRecord.dateCreated = Date()

        let realm = try! Realm()
        try! realm.write {
            realm.add(userRecord)
        }
    }

    func clearData() {
        birthdayTextField.text = nil
        genderTextField.text = nil
        jobTextField.text = nil
        nameTextField.text = nil
        memoTextView.text = nil
        timeLabel.text = "00:00"
        chartsView.data = nil
    }

    // MARK: - Action
    @objc private func showHistory() {
        let vc = HistoryViewController()
        navigationController?.pushViewController(vc, animated: true)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        view.endEditing(true)
    }

    @objc private func birthDateValueChanged(_ sender: UIDatePicker?) {
        guard let date = sender?.date else { return }
        birthdayTextField.text = date.toString(format: "MM/dd/yyyy")
    }

    @objc private func handelDoneClick(_ sender: Any) {
        view.endEditing(true)
    }


    @IBAction func start(_ sender: UIButton) {
        startButton.isEnabled = false
        stopButton.isEnabled = true
        BluetoothManager.shared.startReceivingValue()
        startTimeCounter()
    }


    @IBAction func stop(_ sender: UIButton) {
        startButton.isEnabled = true
        stopButton.isEnabled = false
        BluetoothManager.shared.stopReceivingValue()
        stopTimer()
        storeData()
        clearData()
    }
}

// MARK: - UITextField
extension HomeViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        switch textField {
        case genderTextField:
            let picker = UIPickerView()
            picker.dataSource = self
            picker.delegate = self

            let defaultGender = genderTextField.string == "Female" ? 1 : 0
            picker.selectRow(defaultGender, inComponent: 0, animated: true)

            textField.inputView = picker
            let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
            let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(handelDoneClick(_:)))
            let toolbar = UIToolbar()
            toolbar.sizeToFit()
            toolbar.setItems([space, doneButton], animated: false)
            textField.inputAccessoryView = toolbar
        case birthdayTextField:
            let datePicker = UIDatePicker()
            datePicker.minimumDate = Date(timeIntervalSince1970: 0)
            datePicker.maximumDate = Date()
            datePicker.addTarget(self, action: #selector(birthDateValueChanged(_:)), for: .valueChanged)
            datePicker.datePickerMode = .date

            let defautDate = birthdayTextField.string.toDate(format: "MM/dd/yyyy")
            datePicker.date = defautDate ?? Date()

            textField.inputView = datePicker

            let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
            let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(handelDoneClick(_:)))
            let toolbar = UIToolbar()
            toolbar.sizeToFit()
            toolbar.setItems([space, doneButton], animated: false)
            textField.inputAccessoryView = toolbar
        default: break
        }
        return true
    }
}

extension HomeViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 2
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if row == 0 {
            return "Male"
        } else {
            return "Female"
        }
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        genderTextField.text = row == 0 ? "Male" : "Female"
    }
}

extension String {
    func toDate(format: String) -> Date? {
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = format
        return dateFormat.date(from: self)
    }
}

extension Date {
    func toString(format: String) -> String? {
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = format
        return dateFormat.string(from: self)
    }
}

extension UITextField {
    var string: String {
        return self.text ?? ""
    }
}

extension UITextView {
    var string: String {
        return self.text ?? ""
    }
}
