//
//  AppDelegate.swift
//  Collect
//
//  Created by Adham Amran on 05/08/2018.
//  Copyright © 2018 Adham Amran. All rights reserved.
//

import UIKit
import RealmSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let initialVC = storyboard.instantiateViewController(withIdentifier:  "HomeViewController")
        let launchedFlag = UserDefaults.standard.bool(forKey: "firstImport")
        if launchedFlag {
            window?.rootViewController = initialVC
        } else {
            UserDefaults.standard.set(true, forKey: "firstImport")
        }
        
        let destinationPath = Realm.Configuration.defaultConfiguration.fileURL?.path
        let bundlePath = Bundle.main.path(forResource: "default", ofType: "realm")
        let defaultURL = URL(fileURLWithPath: destinationPath!)
        let pathURL = URL(fileURLWithPath: bundlePath!)
        
        if FileManager.default.fileExists(atPath: destinationPath!) {
            print("File exists")
        } else {
            do {
                try FileManager.default.copyItem(at: pathURL, to: defaultURL)
            } catch {
                print(error)
            }
        }
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

