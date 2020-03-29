//
//  UIViewController+Extension.swift
//  VirtualTourist
//
//  Created by Omar Mujtaba on 30/3/20.
//  Copyright © 2020 AmmoLogic Training. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    private func showAlert(title: String, message: String) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alertVC, animated: true)
    }
}
