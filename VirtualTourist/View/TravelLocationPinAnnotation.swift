//
//  TravelLocationPinAnnotation.swift
//  VirtualTourist
//
//  Created by Omar Mujtaba on 31/3/20.
//  Copyright © 2020 AmmoLogic Training. All rights reserved.
//

import Foundation
import MapKit

class TravelLocationPinAnnotation: NSObject, MKAnnotation {
    var pin: Pin
    var placemark: CLPlacemark?
    
    init(pin: Pin) {
        self.pin = pin
        self.placemark = pin.placemark as? CLPlacemark
    }
    
    var coordinate: CLLocationCoordinate2D {
        let lat = CLLocationDegrees(placemark?.location?.coordinate.latitude ?? 0.0)
        let long = CLLocationDegrees(placemark?.location?.coordinate.longitude ?? 0.0)
        return CLLocationCoordinate2D(latitude: lat, longitude: long)
    }
    
    var title: String? {
        return pin.title ?? "Unknown Location"
    }
    
    var subtitle: String? {
        return "\(coordinate.latitude), \(coordinate.longitude)"
    }
}
