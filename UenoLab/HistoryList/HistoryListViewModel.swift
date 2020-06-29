
//
//  HistoryListViewModel.swift
//  UenoLab
//
//  Created by MBP0020 on 12/4/19.
//  Copyright © 2019 UenoLab. All rights reserved.
//

import Foundation
import RealmSwift

final class HistoryListViewModel {
    

    var userRecoreds: Results<UserRecord> {
        return try! Realm().objects(UserRecord.self).sorted(byKeyPath: "dateCreated", ascending: false)
    }
    
    func numberOfSections() -> Int {
        return 1
    }

    func numberOfItems(inSection: Int) -> Int {
        return userRecoreds.count
    }

    func viewModelForItem(at indexPath: IndexPath) -> UserRecord {
        return userRecoreds[indexPath.row]
    }
}
