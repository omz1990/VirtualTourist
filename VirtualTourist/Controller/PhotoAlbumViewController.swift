//
//  PhotoAlbumViewController.swift
//  VirtualTourist
//
//  Created by Omar Mujtaba on 29/3/20.
//  Copyright © 2020 AmmoLogic Training. All rights reserved.
//

import UIKit
import MapKit

class PhotoAlbumViewController: UIViewController {
    
    // MARK: View Outlets
    @IBOutlet private weak var mapView: MKMapView!
    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var newCollectionButton: UIButton!
    @IBOutlet private weak var errorLabel: UILabel!
    
    var dataController: DataController!
    var pin: Pin!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        populateMapData()
    }
    
    private func populateMapData() {
        let annotation = TravelLocationPinAnnotation(pin: pin)
        
        self.mapView.addAnnotation(annotation)
        // Zoom into the selected location
        self.mapView.showAnnotations([annotation], animated: true)
        // Make sure the title is shown without having to tap the pin
        self.mapView.selectAnnotation(annotation, animated: true)
    }


    @IBAction func newCollectionButtonTap(_ sender: Any) {
    }
}

extension PhotoAlbumViewController: MKMapViewDelegate {
    
    // Set Map Pins UI
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView

        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .red
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
}
