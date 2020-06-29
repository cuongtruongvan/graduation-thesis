//
//  HistoryDetailViewController.swift
//  UenoLab
//
//  Created by MBP0020 on 12/4/19.
//  Copyright © 2019 UenoLab. All rights reserved.
//

import UIKit
import Charts

class HistoryDetailViewController: UIViewController {

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var genderTextField: UITextField!
    @IBOutlet weak var jobTextField: UITextField!
    @IBOutlet weak var birthdayTextField: UITextField!
    @IBOutlet weak var memoTextView: UITextView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var chartsView: LineChartView!

    var userRecorded: UserRecord?
    var lineChartEntries: [ChartDataEntry] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        if let name = userRecorded?.name {
            title = name.isEmpty ? "Unnamed" : name
        }
        setupData()
        setupView()
        setupGraphData()
    }

    func setupData() {
        guard let userRecorded = userRecorded else { return }
        nameTextField.text = userRecorded.name.isEmpty ? "Unnamed" : userRecorded.name
        genderTextField.text = userRecorded.gender.isEmpty ? "Unknow" : userRecorded.gender
        jobTextField.text = userRecorded.job.isEmpty ? "Unknow" : userRecorded.job
        birthdayTextField.text = userRecorded.birthday.isEmpty ? "Unknow" : userRecorded.birthday
        memoTextView.text = userRecorded.memo.isEmpty ? "Unknow" : userRecorded.memo
    }

    private func setupView() {
        chartsView.chartDescription?.enabled = false
        chartsView.noDataText = "No data is available now. Please hit `Start` button"
        chartsView.gridBackgroundColor = NSUIColor.purple
        chartsView.rightAxis.enabled = false
        chartsView.legend.enabled = false
        chartsView.xAxis.enabled = true
        chartsView.xAxis.labelPosition = .bottom
        chartsView.pinchZoomEnabled = true
        chartsView.dragXEnabled = true
    }

    private func setupGraphData() {
        //Prepare Line Data
        guard let rawData = userRecorded?.heartBeat else { return }
        for item in rawData {
            let value = ChartDataEntry(x: item.xValue, y: item.yValue)
            lineChartEntries.append(value)
        }
        // Setup line appearance
        let set1 = LineChartDataSet(entries: lineChartEntries, label: "Heart beat")
        set1.mode = .cubicBezier
        set1.axisDependency = .left
        set1.colors = [NSUIColor.red]
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
        chartsView.setVisibleXRangeMaximum(7.0)
        if let last = rawData.last {
            chartsView.moveViewToX(last.xValue)
        }
    }
}
