//
//  MKCoordinateRegion+Extension.swift
//  VirtualTourist
//
//  Created by Omar Mujtaba on 30/3/20.
//  Copyright © 2020 AmmoLogic Training. All rights reserved.
//

import Foundation
import MapKit

// MARK: Save Map region to UserDefaults Helpers
extension MKCoordinateRegion {
    
    // Reference: https://stackoverflow.com/a/60367718/10510927
    public func write(toDefaults defaults: UserDefaults, withKey key: String) {
        let locationData = [center.latitude, center.longitude, span.latitudeDelta, span.longitudeDelta]
        defaults.set(locationData, forKey: key)
    }

    public static func load(fromDefaults defaults:UserDefaults, withKey key:String) -> MKCoordinateRegion? {
        guard let region = defaults.object(forKey: key) as? [Double] else { return nil }
        let center = CLLocationCoordinate2D(latitude: region[0], longitude: region[1])
        let span = MKCoordinateSpan(latitudeDelta: region[2], longitudeDelta: region[3])
        return MKCoordinateRegion(center: center, span: span)
    }
}
