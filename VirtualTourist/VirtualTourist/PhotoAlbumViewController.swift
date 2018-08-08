//
//  PhotoAlbumViewController.swift
//  VirtualTourist
//
//  Created by Bernadett Kiss on 7/23/18.
//  Copyright © 2018 Bernadett Kiss. All rights reserved.
//

import UIKit
import CoreData

class PhotoAlbumViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, NSFetchedResultsControllerDelegate {
    
    @IBOutlet weak var photoCollectionView: UICollectionView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var newCollectionButton: UIButton!
    
    var selectedPin: Pin!
    var dataController: DataController!
    var fetchedResultsController: NSFetchedResultsController<Photo>!
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        photoCollectionView.dataSource = self
        photoCollectionView.delegate = self
        configureFlowLayout()
        setUpFetchedResultsController()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        fetchedResultsController = nil
    }
    
    // MARK: - Actions
    
    @IBAction func newCollectionButtonPressed(_ sender: UIButton) {
        newCollectionButton.isEnabled = false
        photoCollectionView.reloadData()
        dataController.fetchPhotos(for: selectedPin) { success in
            DispatchQueue.main.async {
                self.newCollectionButton.isEnabled = true
            }
            if success {
                try? self.fetchedResultsController.performFetch()
                DispatchQueue.main.async {
                    self.photoCollectionView.reloadData()
                }
            }
        }
    }
    
    // MARK: - Methods
    
    func configureFlowLayout() {
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
    
    func setUpFetchedResultsController() {
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
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[0].numberOfObjects ?? 21
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellReuseIdentifier, for: indexPath) as! PhotoCollectionViewCell
        cell.update(with: nil)
        let photo = fetchedResultsController.object(at: indexPath)
        
        if photo.image == nil {
            if let imageURL = photo.remoteURL {
                if let imageData = try? Data(contentsOf: imageURL as URL) {
                    photo.image = imageData
                    try? dataController.viewContext.save()
                    let image = UIImage(data: imageData)
                    DispatchQueue.main.async {
                        cell.update(with: image)
                    }
                }
            }
        } else {
            let image = UIImage(data: photo.image!)
            cell.update(with: image)
        }
        return cell
    }
}
