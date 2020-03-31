//
//  PhotoAlbumViewController.swift
//  VirtualTourist
//
//  Created by Omar Mujtaba on 29/3/20.
//  Copyright © 2020 AmmoLogic Training. All rights reserved.
//

import UIKit
import MapKit

class PhotoAlbumViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    // MARK: View Outlets
    @IBOutlet private weak var mapView: MKMapView!
    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var newCollectionButton: UIButton!
    @IBOutlet private weak var errorLabel: UILabel!
    
    var dataController: DataController!
    var pin: Pin!
    var placemark: CLPlacemark!
    
    var photosList: [PhotoResponse]?
    
    override func viewWillAppear(_ animated: Bool) {
        placemark = pin.placemark as? CLPlacemark
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setCellSize()
        populateMapData()
        
        activityIndicator?.startAnimating()
        errorLabel?.text = ""
        
        placemark = pin.placemark as? CLPlacemark
        FlickrClient.searchPhotos(lat: "\(placemark?.location?.coordinate.latitude ?? 0.0)", long: "\(placemark?.location?.coordinate.longitude ?? 0.0)", completion: handleSearchResponse(photos:error:))
    }
    
    private func handleSearchResponse(photos: [PhotoResponse]?, error: Error?) {
        activityIndicator?.stopAnimating()
        guard let photos = photos else {
            errorLabel?.text = "No images found"
            return
        }
        photosList = photos
        collectionView.reloadData()
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
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photosList?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionCell", for: indexPath) as! PhotoAlbumCell
    
        if let photo = photosList?[(indexPath as IndexPath).row] {
            FlickrClient.downloadPhoto(photo: photo) { (image, error) in
                cell.image?.image = image
            }
        }
        
        return cell
    }
    
    // MARK: Set collection view cell size
    private func setCellSize() {
        let space: CGFloat = 3.0
        let dimension = calculteCellSize(space)
    
        flowLayout.minimumInteritemSpacing = space
        flowLayout.minimumLineSpacing = space
        flowLayout.itemSize = CGSize(width: dimension, height: dimension)
    }
    
    private func calculteCellSize(_ space: CGFloat) -> CGFloat {
        let screenWidth = view.frame.size.width
        let screenHeight = view.frame.size.height
        
        // Select a baseWidth to calculate the cell size
        // If the screen is portrait, we should do screenWidth/3
        // If the screen is landscapes we should do screenWidth/3
        let currentScreenOrientation = UIApplication.shared.statusBarOrientation
        let baseWidth = currentScreenOrientation.isPortrait ? screenWidth : screenHeight

        return (baseWidth - (2 * space)) / 3.0
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
