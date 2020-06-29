//
//  BaseViewController.swift
//  UenoLab
//
//  Created by UenoLab on 9/11/19.
//  Copyright © 2019 UenoLab. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {
    func alert(title: String = "", message: String, completion: ((UIAlertAction) -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .cancel, handler: completion)
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configNavi()
    }
    
    func configNavi(){
//        self.edgesForExtendedLayout = []
        navigationController?.navigationBar.isTranslucent = false
    }
}
