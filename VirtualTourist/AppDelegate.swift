//
//  AppDelegate.swift
//  VirtualTourist
//
//  Created by Omar Mujtaba on 28/3/20.
//  Copyright © 2020 AmmoLogic Training. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window : UIWindow?
    
    let dataController = DataController(modelName: "VirtualTourist")
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.rn true
        initDataController()
        return true
    }
    
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        saveViewContext()
    }
    
    private func initDataController() {
        // iOS 13 and above use SceneDelegate for this
        guard #available(iOS 13.0, *) else {
            dataController.load()
            let navigationController = window?.rootViewController as! UINavigationController
            let viewController = navigationController.topViewController as! TravelLocationsMapViewController
            viewController.dataController = dataController
            return
        }
    }
    
    func saveViewContext() {
        // iOS 13 and above use SceneDelegate for this
        guard #available(iOS 13.0, *) else {
            try? dataController.viewContext.save()
            return
        }
    }

}

