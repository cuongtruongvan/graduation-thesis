//
//  UserRecord.swift
//  UenoLab
//
//  Created by MBP0020 on 12/4/19.
//  Copyright © 2019 UenoLab. All rights reserved.
//

import Foundation
import RealmSwift

@objcMembers
final class UserRecord: Object {
    dynamic var dateCreated: Date?
    dynamic var name = ""
    dynamic var birthday = "01/01/1970"
    dynamic var gender = ""
    dynamic var job = ""
    dynamic var memo = ""
    let heartBeat = List<DrawObject>()

}

@objcMembers final class DrawObject: Object {
    dynamic var xValue: Double = 0
    dynamic var yValue: Double = 0
}
