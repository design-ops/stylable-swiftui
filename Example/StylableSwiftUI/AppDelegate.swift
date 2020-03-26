//
//  AppDelegate.swift
//  SwiftUIStylist
//
//  Created by deanWombourne on 01/13/2020.
//  Copyright (c) 2020 deanWombourne. All rights reserved.
//

import Foundation
import UIKit

import StylableSwiftUI

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        // Enable this so we can use Instruments to see a good solid trace when calculating image names
//        let identifier: StylistIdentifier = "a/b/c/d/e/f/g/h/i/j/k/l/m/n/o" // /p/q/r/s/t/u/v/w/x/y/z"
//        _ = identifier.potentialImageNames().map { $0 }
//
//        Thread.sleep(forTimeInterval: 100)

        // Override point for customization after application launch.
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
}
