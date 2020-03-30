//
//  SceneDelegate.swift
//  VirtualTourist
//
//  Created by Omar Mujtaba on 28/3/20.
//  Copyright © 2020 AmmoLogic Training. All rights reserved.
//

import UIKit

@available(iOS 13.0, *)
class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    let dataController = DataController(modelName: "VirtualTourist")

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        dataController.load()
        
        let navigationController = window?.rootViewController as! UINavigationController
        let viewController = navigationController.topViewController as! TravelLocationsMapViewController
        viewController.dataController = dataController
        
        guard let _ = (scene as? UIWindowScene) else { return }
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        saveViewContext()
    }

    func saveViewContext() {
        try? dataController.viewContext.save()
    }

}

