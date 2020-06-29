//
//  AppDelegate.swift
//  UenoLab
//
//  Created by UenoLab on 9/11/19.
//  Copyright © 2019 UenoLab. All rights reserved.
//

import UIKit
import SVProgressHUD
import IQKeyboardManager
import RealmSwift

typealias hud = SVProgressHUD
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {


    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        setupHUD()
        setupIQKeyboard()
        setupRealm()
        window = UIWindow(frame: UIScreen.main.bounds)
        let vc = HomeViewController()
        let navi = UINavigationController(rootViewController: vc)
        window?.rootViewController = navi
        window?.makeKeyAndVisible()
        return true
    }

    func setupHUD() {
        hud.setDefaultMaskType(.clear)
    }

    func setupIQKeyboard() {
        IQKeyboardManager.shared().isEnabled = true
//        IQKeyboardManager.shared().previousNextDisplayMode = .alwaysHide
    }

    func setupRealm() {
        Realm.Configuration.defaultConfiguration = Realm.Configuration(
            schemaVersion: 1,
            deleteRealmIfMigrationNeeded: true
        )
        _ = try? Realm()
        print(Realm.Configuration.defaultConfiguration.fileURL?.absoluteString ?? "")
    }
}

