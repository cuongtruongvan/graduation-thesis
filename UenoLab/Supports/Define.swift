//
//  Define.swift
//  UenoLab
//
//  Created by UenoLab on 9/11/19.
//  Copyright © 2019 UenoLab. All rights reserved.
//

import Foundation

extension NSNotification.Name {
    static let didDiscoverPeripheralNotificationName = NSNotification.Name("didDiscoverPeripheral")
    static let didConnectPeripheralNotificationName = NSNotification.Name("didConnectPeripheral")
    static let didUpdateBluetoothStateNotificationName = NSNotification.Name("didUpdateBluetoothState")
    static let didUpdateBluetoothDataNotificationName = NSNotification.Name("didUpdateBluetoothData")
}
