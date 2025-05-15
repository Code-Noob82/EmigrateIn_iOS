//
//  AppDelegate.swift
//  Expat App
//
//  Created by Dominik Baki on 15.05.25.
//

import Foundation
import UIKit
import Firebase
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        print("AppDelegate: Firebase wurde in didFinishLaunchingWithOptions konfiguriert.")
        return true
    }
}
