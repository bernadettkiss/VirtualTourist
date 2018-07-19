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
    
    let dataController = DataController(modelName: "VirtualTourist")
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        dataController.load()
        
        let navigationController = window?.rootViewController as! UINavigationController
        let travelLocationViewController = navigationController.topViewController as! TravelLocationsMapViewController
        travelLocationViewController.dataController = dataController
        
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        saveViewContext()
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        saveViewContext()
    }
    
    // MARK: - Core Data Saving Support
    
    func saveViewContext() {
        try? dataController.viewContext.save()
    }
}
