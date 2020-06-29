//
//  HistoryTableViewCell.swift
//  UenoLab
//
//  Created by MBP0020 on 12/4/19.
//  Copyright © 2019 UenoLab. All rights reserved.
//

import UIKit

class HistoryTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var birthdayLabel: UILabel!
    @IBOutlet weak var createdDateLabel: UILabel!
    
    var userRecord: UserRecord = UserRecord() {
        didSet {
            nameLabel.text = userRecord.name
            birthdayLabel.text = userRecord.birthday
            createdDateLabel.text = userRecord.dateCreated?.toString(format: "MM/dd/yyyy HH:mm:ss")
        }
    }
}
