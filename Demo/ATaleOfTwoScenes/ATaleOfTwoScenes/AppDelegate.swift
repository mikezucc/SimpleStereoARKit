//
//  AppDelegate.swift
//  ATaleOfTwoScenes
//
//  Created by Michael Zuccarino on 6/20/17.
//  Copyright © 2017 Michael Zuccarino. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = DualViewController()
        window?.makeKeyAndVisible()

        return true
    }

}

