//
//  UIViewController+Extension.swift
//  VirtualTourist
//
//  Created by Omar Mujtaba on 30/3/20.
//  Copyright © 2020 AmmoLogic Training. All rights reserved.
//

import Foundation
import UIKit
import MapKit

extension UIViewController {
    
    func buildPinTitle(placemark: CLPlacemark?) -> String {
        guard let placemark = placemark else {
            return "Unknown Location"
        }
        
        let name = placemark.name == nil ? "" : "\(placemark.name!), "
        let city = placemark.locality == nil ? "" : "\(placemark.locality!), "
        let country = placemark.country ?? ""
        let title = "\(name)\(city)\(country)"
        
        if title.isEmpty {
            return "Unknown Location"
        } else {
            return title
        }
    }
    
    private func showAlert(title: String, message: String) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alertVC, animated: true)
    }
}
