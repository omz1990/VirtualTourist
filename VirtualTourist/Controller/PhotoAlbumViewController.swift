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
    var placemark: CLPlacemark!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        populateMapData()
    }
    
    private func populateMapData() {
        var annotations = [MKPointAnnotation]()
        
        let lat = CLLocationDegrees(placemark?.location?.coordinate.latitude ?? 0.0)
        let long = CLLocationDegrees(placemark?.location?.coordinate.longitude ?? 0.0)
        let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = buildPinTitle(placemark: placemark)
        annotation.subtitle = "\(coordinate.latitude), \(coordinate.longitude)"
        annotations.append(annotation)
        
        self.mapView.addAnnotation(annotation)
        // Zoom into the selected location
        self.mapView.showAnnotations(annotations, animated: true)
        // Make sure the title is shown without having to tap the pin
        self.mapView.selectAnnotation(annotation, animated: true)
    }

    @IBAction func newCollectionButtonTap(_ sender: Any) {
    }
}
