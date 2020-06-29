//
//  BluetoothManager.swift
//  UenoLab
//
//  Created by UenoLab on 9/11/19.
//  Copyright © 2019 UenoLab. All rights reserved.
//

import UIKit
import CoreBluetooth

protocol BluetoothManagerDelegate {
    func bluetoothManager(_ manager: BluetoothManager, didUpdate state: CBManagerState)
}

@objcMembers
class BluetoothManager: NSObject {
    static let shared = BluetoothManager()

    private var myCentralManager: CBCentralManager!
    private var myPeripheral: CBPeripheral!
    let uenoLabUUID = CBUUID(string: "F2AEA438-C4B3-11E9-AA8C-2A2AE2DBCCE4")
    var devices: [CBPeripheral] = []
    var bluetoothState: CBManagerState = .unknown
    private var isReceivingData = false

    private override init() {
        super.init()
        myCentralManager = CBCentralManager(delegate: self, queue: nil)
    }

    func connect(to peripheral: CBPeripheral) {
        myPeripheral = peripheral
        myPeripheral.delegate = self
        myCentralManager.connect(myPeripheral)
        stopScan()
    }

    func stopScan() {
        myCentralManager.stopScan()
    }

    func startScan() {
        let devices = myCentralManager.retrieveConnectedPeripherals(withServices: [uenoLabUUID])
        if devices.isEmpty {
            myCentralManager.scanForPeripherals(withServices: nil)
        }
    }

    func startReceivingValue() {
        isReceivingData = true
    }

    func stopReceivingValue() {
        isReceivingData = false
    }
}

extension BluetoothManager: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        bluetoothState = central.state
        NotificationCenter.default.post(name: .didUpdateBluetoothStateNotificationName, object: nil)
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any], rssi RSSI: NSNumber) {

        let currectDevices = devices.filter { (per) -> Bool in
            per.identifier == peripheral.identifier
        }

        if currectDevices.isEmpty, peripheral.name != nil {
            devices.append(peripheral)
            print(peripheral)
            NotificationCenter.default.post(name: .didDiscoverPeripheralNotificationName, object: nil)
        }
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        if myPeripheral == peripheral {
            myPeripheral.discoverServices(nil)
            NotificationCenter.default.post(name: .didConnectPeripheralNotificationName, object: nil)
        }
    }

    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        if peripheral == myPeripheral {
            myCentralManager.scanForPeripherals(withServices: nil)
        }
    }
}

extension BluetoothManager: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }
        for service in services {
            print("Service \(service)")
            peripheral.discoverCharacteristics([uenoLabUUID], for: service)
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else { return }
        for characteristic in characteristics {
            if characteristic.properties.contains(.notify) {
                myPeripheral.setNotifyValue(true, for: characteristic)
            } else {
                myPeripheral.readValue(for: characteristic)
            }
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if characteristic.uuid.uuidString == "F2AEA438-C4B3-11E9-AA8C-2A2AE2DBCCE4" {
            readLoopValue(from: characteristic)
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didModifyServices invalidatedServices: [CBService]) {
        print(invalidatedServices)
    }

    private func readLoopValue(from characteristic: CBCharacteristic) {
        if isReceivingData {
            guard let dataReceived = characteristic.value else { return }
            let byteArray = [UInt8](dataReceived)
            guard let stringData1 = String(bytes: byteArray, encoding: .utf8) else { return }
            print("From StringData1 \(stringData1.replacingOccurrences(of: "\r\n", with: " "))")
            let array = stringData1.components(separatedBy: "\r\n").compactMap({ return Int($0) })
            NotificationCenter.default.post(name: .didUpdateBluetoothDataNotificationName, object: array)
        }
    }
}
