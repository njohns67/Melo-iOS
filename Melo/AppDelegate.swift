//
//  AppDelegate.swift
//  Melo
//
//  Created by Nathan Johnston on 11/8/19.
//  Copyright © 2019 Nathan Johnston. All rights reserved.
//

import UIKit
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    // MARK: UISceneSession Lifecycle

      func application(_ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions:
        [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        print("Launched")

        if let url = launchOptions?[UIApplication.LaunchOptionsKey.url] as? URL {
           print(url)
        }
        FirebaseApp.configure()
        return true
      }
    func application(_ application: UIApplication,
                     willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool{
        if let url = launchOptions?[UIApplication.LaunchOptionsKey.url] as? URL {
           print(url)
        }
        return true
    }
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
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        print("fired")
        let message = url.host?.removingPercentEncoding
        print(message)
        return true
    }
    

}

