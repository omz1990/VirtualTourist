//
//  TravelLocationsMapViewController.swift
//  VirtualTourist
//
//  Created by Omar Mujtaba on 28/3/20.
//  Copyright © 2020 AmmoLogic Training. All rights reserved.
//

import UIKit
import MapKit

class TravelLocationsMapViewController: UIViewController {

    @IBOutlet private weak var mapView: MKMapView!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    private var selectedPinPlacemark: CLPlacemark!
    private let mapRegion = "region"
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Try to load the saved region from UserDefaults
        if let region = MKCoordinateRegion.load(fromDefaults: UserDefaults.standard, withKey: mapRegion) {
          mapView.region = region
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLongPressListenerOnMap()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == Constants.Segue.showAlbumSegue) {
            let vc = segue.destination as! PhotoAlbumViewController
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Save the map region when the view is about to disappear
        mapView.region.write(toDefaults: UserDefaults.standard, withKey: mapRegion)
    }
    
}

// MARK: Maps Extension
extension TravelLocationsMapViewController: MKMapViewDelegate {
    
    // Setup Long Press Listener
    private func setupLongPressListenerOnMap() {
        let uilgr = UILongPressGestureRecognizer(target: self, action: #selector(addAnnotation(gestureRecognizer:)))
        uilgr.minimumPressDuration = 1.0
        mapView.addGestureRecognizer(uilgr)
        
    }
    
    // Add Pin to map on long press
    @objc private func addAnnotation(gestureRecognizer: UIGestureRecognizer) {
        if gestureRecognizer.state == UIGestureRecognizer.State.began {
            
            let touchPoint = gestureRecognizer.location(in: mapView)
            let newCoordinates = mapView.convert(touchPoint, toCoordinateFrom: mapView)
            
            getLocationData(coordinates: newCoordinates, completion: addAnnotationPinToMap(coordinates:placemark:error:))
            
        }
    }
    
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
    
    // Handle Map Pin tap
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        performSegue(withIdentifier: Constants.Segue.showAlbumSegue, sender: nil)
    }
    
    fileprivate func getLocationData(coordinates: CLLocationCoordinate2D, completion: @escaping (CLLocationCoordinate2D,CLPlacemark?, Error?) -> Void) {
        let geocoder = CLGeocoder()
        
        activityIndicator?.startAnimating()
        
        geocoder.reverseGeocodeLocation(CLLocation(latitude: coordinates.latitude, longitude: coordinates.longitude)) { (placemarks, error) in
            if let placemark = placemarks?[0] {
                completion(coordinates, placemark, nil)
            } else {
                completion(coordinates, nil, error)
            }
        }
    }
    
    fileprivate func addAnnotationPinToMap(coordinates: CLLocationCoordinate2D, placemark: CLPlacemark?, error: Error?) {
        
        activityIndicator?.stopAnimating()
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinates
        annotation.title = buildPinTitle(placemark: placemark)
        annotation.subtitle = "\(coordinates.latitude), \(coordinates.longitude)"
        mapView.addAnnotation(annotation)
        mapView.selectAnnotation(annotation, animated: true)
    }
}
