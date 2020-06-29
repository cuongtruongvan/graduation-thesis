//
//  ScanDeviceViewController.swift
//  UenoLab
//
//  Created by UenoLab on 9/11/19.
//  Copyright © 2019 UenoLab. All rights reserved.
//

import UIKit
import CoreBluetooth

class ScanDeviceViewController: BaseViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var indicator: UIActivityIndicatorView!

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Scan Device"
        setupNaviItem()
        setupTableView()
        addObserver()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        BluetoothManager.shared.startScan()
        indicator.startAnimating()
    }

    func setupNaviItem() {
        let item = UIBarButtonItem(title: "Refresh", style: .plain, target: self, action: #selector(refresh))
        navigationItem.rightBarButtonItem = item
    }

    private func setupTableView() {

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "device_cell")
        tableView.delegate = self
        tableView.dataSource = self
    }

    private func addObserver() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(newDeviceFound(notify:)),
                                               name: .didDiscoverPeripheralNotificationName,
                                               object: nil
        )
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(connectedDevice(notify:)),
                                               name: .didConnectPeripheralNotificationName,
                                               object: nil
        )
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(bluetoothStateChanged(notify:)),
                                               name: .didUpdateBluetoothStateNotificationName,
                                               object: nil
        )
    }

    @objc private func newDeviceFound(notify: Notification) {
        tableView.reloadData()
    }

    @objc private func connectedDevice(notify: Notification) {
        tableView.reloadData()
        hud.popActivity()
        indicator.stopAnimating()
        alert(message: "Connected") { (_) in
            let homeVC = HomeViewController()
            self.navigationController?.pushViewController(homeVC, animated: true)
        }
    }

    @objc private func bluetoothStateChanged(notify: Notification) {
        let state = BluetoothManager.shared.bluetoothState
        if state == .poweredOn {
            BluetoothManager.shared.startScan()
        } else {
            alert(message: "Please check Bluetooth condition")
            indicator.stopAnimating()
        }
    }

    @objc func refresh() {
        BluetoothManager.shared.devices.removeAll()
        tableView.reloadData()
        BluetoothManager.shared.startScan()
    }
}

extension ScanDeviceViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return BluetoothManager.shared.devices.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "device_cell") else { return UITableViewCell() }
        let item = BluetoothManager.shared.devices[indexPath.row]
        cell.textLabel?.text = item.name ?? "unknow"
        if item.state == .connected {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let item = BluetoothManager.shared.devices[indexPath.row]
        if item.state == .connected {
            let homeVC = HomeViewController()
            self.navigationController?.pushViewController(homeVC, animated: true)
        } else {
            hud.show()
            BluetoothManager.shared.connect(to: item)
        }
    }
}
