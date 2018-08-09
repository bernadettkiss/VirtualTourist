//
//  AppDelegate.swift
//  VirtualTourist
//
//  Created by Bernadett Kiss on 7/16/18.
//  Copyright © 2018 Bernadett Kiss. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    public var appLaunchedBefore: Bool?
    
    let dataController = DataController(modelName: "VirtualTourist")
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        if UserDefaults.standard.bool(forKey: "appLaunchedBefore") {
            appLaunchedBefore = true
        } else {
            appLaunchedBefore = false
            UserDefaults.standard.set(true, forKey: "appLaunchedBefore")
        }
        
        dataController.load()
        
        let navigationController = window?.rootViewController as! UINavigationController
        let travelLocationViewController = navigationController.topViewController as! TravelLocationsMapViewController
        travelLocationViewController.dataController = dataController
        
        return true
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        saveViewContext()
        MapConfig.shared.save()
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        saveViewContext()
        MapConfig.shared.save()
    }
    
    // MARK: - Core Data Saving Support
    
    func saveViewContext() {
        if dataController.viewContext.hasChanges {
            try? dataController.viewContext.save()
        }
    }
}
