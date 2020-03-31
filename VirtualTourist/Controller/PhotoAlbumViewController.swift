//
//  PhotoAlbumViewController.swift
//  VirtualTourist
//
//  Created by Omar Mujtaba on 29/3/20.
//  Copyright © 2020 AmmoLogic Training. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class PhotoAlbumViewController: UIViewController {
    
    // MARK: View Outlets
    @IBOutlet private weak var mapView: MKMapView!
    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var flowLayout: UICollectionViewFlowLayout!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var newCollectionButton: UIButton!
    @IBOutlet private weak var errorLabel: UILabel!
    
    // MARK: Class Variables
    var dataController: DataController!
    var pin: Pin!
    private var placemark: CLPlacemark!
    private var fetchedResultsController: NSFetchedResultsController<Photo>!
    private var blockOperation = BlockOperation()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setCellSize()
        populateMapData()
        
        placemark = pin.placemark as? CLPlacemark
        
        setupFetchedResultsController()

        // If we don't have any photos, fetch from the API
        if (pin.photos?.count ?? 0 == 0) {
            fetchPhotosFromApi()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        fetchedResultsController = nil
    }
    
    // MARK: Fetch and Save Photos
    private func fetchPhotosFromApi() {
        activityIndicator?.startAnimating()
        errorLabel?.text = ""
        
        FlickrClient.searchPhotos(lat: "\(placemark?.location?.coordinate.latitude ?? 0.0)", long: "\(placemark?.location?.coordinate.longitude ?? 0.0)", completion: handleSearchApiResponse(photos:error:))
    }
    
    private func handleSearchApiResponse(photos: [PhotoResponse]?, error: Error?) {
        activityIndicator?.stopAnimating()
        guard let photos = photos else {
            errorLabel?.text = "No images found"
            return
        }
        savePhotos(photos: photos)
    }
    
    private func savePhotos(photos: [PhotoResponse]) {
        photos.forEach { (photoResponse) in
            let newPhoto = Photo(context: dataController.viewContext)
            newPhoto.pin = pin
            newPhoto.photoId = photoResponse.id
            newPhoto.title = photoResponse.title
            newPhoto.photoUrl = FlickrClient.Endpoints.getPhoto(farmId: photoResponse.farm, serverId: photoResponse.server, photoId: photoResponse.id, photoSecret: photoResponse.secret).stringValue
            
            do {
                try dataController.viewContext.save()
            } catch {
                showAlert(title: "Error", message: error.localizedDescription)
            }
        }
    }

    @IBAction func newCollectionButtonTap(_ sender: Any) {
        // TODO
    }
    
}

// MARK: Extension to handle Collection View
extension PhotoAlbumViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchedResultsController?.sections?[section].numberOfObjects ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cellPhoto = fetchedResultsController.object(at: indexPath)
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionCell", for: indexPath) as! PhotoAlbumCell
        if let url = cellPhoto.photoUrl {
            if let downloadedData = cellPhoto.image {
                if let downloadedImage = UIImage(data: downloadedData) {
                    cell.image?.image = downloadedImage
                }
            } else {
                FlickrClient.downloadPhoto(urlString: url) { (image, error) in
                    guard let image = image else {
                        return
                    }
                    cellPhoto.image = image.jpegData(compressionQuality: 1.0)
                    try? self.dataController.viewContext.save()
                }
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cellPhoto = fetchedResultsController.object(at: indexPath)
        
        let alert = UIAlertController(title: "Delete image", message: "Are you sure you want to delete the selected image?", preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let deleteAction = UIAlertAction(title: "Delete", style: .default) { (action) in
            self.dataController.viewContext.delete(cellPhoto)
            try? self.dataController.viewContext.save()
        }
        
        alert.addAction(cancelAction)
        alert.addAction(deleteAction)
        present(alert, animated: true, completion: nil)

    }
    
    // MARK: Set collection view cell size helpers
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

// MARK: NSFetchedResultsControllerDelegate
extension PhotoAlbumViewController: NSFetchedResultsControllerDelegate {
    
    private func setupFetchedResultsController() {
        // Fetch photos for the current Pin
        let fetchRequest: NSFetchRequest<Photo> = Photo.fetchRequest()
        let predicate = NSPredicate(format: "pin == %@", pin)
        fetchRequest.predicate = predicate
        let sortDescriptor = NSSortDescriptor(key: "photoId", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: "\(pin.objectID)")
        fetchedResultsController.delegate = self
        try? fetchedResultsController.performFetch()
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        blockOperation = BlockOperation()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            guard let newIndexPath = newIndexPath else { break }
            
            blockOperation.addExecutionBlock {
                self.collectionView?.insertItems(at: [newIndexPath])
            }
        case .update:
            guard let indexPath = indexPath else { break }
            
            blockOperation.addExecutionBlock {
                self.collectionView?.reloadItems(at: [indexPath])
            }
        case .delete:
            guard let indexPath = indexPath else { break }
            
            blockOperation.addExecutionBlock {
                self.collectionView?.deleteItems(at: [indexPath])
            }
        default:
            break
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        collectionView?.performBatchUpdates({
            self.blockOperation.start()
            }, completion: nil)
    }
}

// MARK: Extension to handle Map
extension PhotoAlbumViewController: MKMapViewDelegate {
    
    private func populateMapData() {
        let annotation = TravelLocationPinAnnotation(pin: pin)
        
        mapView.addAnnotation(annotation)
        // Zoom into the selected location
        mapView.showAnnotations([annotation], animated: true)
        // Make sure the title is shown without having to tap the pin
        mapView.selectAnnotation(annotation, animated: true)
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
}
