//
//  PhotoAlbumViewController.swift
//  VirtualTourist
//
//  Created by Bernadett Kiss on 7/23/18.
//  Copyright © 2018 Bernadett Kiss. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class PhotoAlbumViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var photoCollectionView: UICollectionView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var newCollectionButton: UIButton!
    @IBOutlet weak var noPhotosLabel: UILabel!
    
    var selectedPin: Pin!
    var dataController: DataController!
    var fetchedResultsController: NSFetchedResultsController<Photo>!
    let cellReuseIdentifier = "PhotoCell"
    var insertedIndexPaths: [IndexPath]!
    var deletedIndexPaths: [IndexPath]!
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        photoCollectionView.dataSource = self
        photoCollectionView.delegate = self
        navigationItem.rightBarButtonItem = editButtonItem
        showOnMap(selectedPin)
        configureView()
        configureFlowLayout()
        setUpFetchedResultsController()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let photos = selectedPin.photos, photos.anyObject() == nil {
            dataController.fetchPhotos(for: selectedPin) { success in
                self.configureView()
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        fetchedResultsController = nil
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        newCollectionButton.isEnabled = !editing
    }
    
    // MARK: - Actions
    
    @IBAction func newCollectionButtonPressed(_ sender: UIButton) {
        newCollectionButton.isEnabled = false
        if let numberOfPhotos = fetchedResultsController.sections?[0].numberOfObjects {
            for index in 0..<numberOfPhotos {
                let cell = photoCollectionView.cellForItem(at: IndexPath(item: index, section: 0)) as? PhotoCollectionViewCell
                cell?.loading = true
            }
        }
        dataController.fetchPhotos(for: selectedPin) { success in
            DispatchQueue.main.async {
                self.newCollectionButton.isEnabled = true
            }
        }
    }
    
    // MARK: - Methods
    
    private func configureView() {
        if self.selectedPin.flickrPage?.total == 0 {
            DispatchQueue.main.async {
                self.editButtonItem.isEnabled = false
                self.newCollectionButton.isHidden = true
                self.noPhotosLabel.isHidden = false
            }
        }
    }
    
    private func showOnMap(_ pin: Pin) {
        let annotation = MKPointAnnotation()
        let coordinate = CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude)
        annotation.coordinate = coordinate
        mapView.addAnnotation(annotation)
        mapView.setRegion(MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)), animated: true)
        mapView.isUserInteractionEnabled = false
    }
    
    private func configureFlowLayout() {
        let space: CGFloat = 3.0
        var numberOfColumns: CGFloat = 3
        if view.frame.size.width > view.frame.size.height {
            numberOfColumns = 5.0
        }
        let dimension = (view.frame.size.width - ((numberOfColumns - 1) * space)) / numberOfColumns
        
        flowLayout.minimumInteritemSpacing = space
        flowLayout.minimumLineSpacing = space
        flowLayout.itemSize = CGSize(width: dimension, height: dimension)
    }
    
    private func setUpFetchedResultsController() {
        let fetchRequest: NSFetchRequest<Photo> = Photo.fetchRequest()
        let predicate = NSPredicate(format: "pin == %@", selectedPin)
        fetchRequest.predicate = predicate
        let sortDescriptor = NSSortDescriptor(key: "photoID", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }
    
    // MARK: - CollectionViewDataSource Methods
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[0].numberOfObjects ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellReuseIdentifier, for: indexPath) as! PhotoCollectionViewCell
        let photo = fetchedResultsController.object(at: indexPath)
        
        if photo.image == nil {
            if let imageURL = photo.remoteURL {
                NetworkManager.shared.downloadImage(imageURL: imageURL as URL) { result in
                    if case let .success(imageData) = result {
                        photo.image = imageData as? Data
                        try? self.dataController.viewContext.save()
                        let image = UIImage(data: imageData as! Data)
                        DispatchQueue.main.async {
                            cell.update(with: image)
                        }
                    }
                }
            }
        } else {
            let image = UIImage(data: photo.image!)
            cell.update(with: image)
        }
        return cell
    }
    
    // MARK: - CollectionViewDelegate Methods
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if isEditing {
            let photoToDelete = fetchedResultsController.object(at: indexPath)
            dataController.viewContext.delete(photoToDelete)
            try? dataController.viewContext.save()
        }
    }
}

extension PhotoAlbumViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        insertedIndexPaths = []
        deletedIndexPaths = []
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        photoCollectionView.performBatchUpdates({
            for insertedIndexPath in self.insertedIndexPaths {
                self.photoCollectionView.insertItems(at: [insertedIndexPath])
            }
            for deletedIndexPath in self.deletedIndexPaths {
                self.photoCollectionView.deleteItems(at: [deletedIndexPath])
            }
        }, completion: nil)
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            insertedIndexPaths.append(newIndexPath!)
        case .delete:
            deletedIndexPaths.append(indexPath!)
        default:
            ()
        }
    }
}
