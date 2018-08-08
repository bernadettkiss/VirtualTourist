//
//  DataController.swift
//  VirtualTourist
//
//  Created by Bernadett Kiss on 7/18/18.
//  Copyright © 2018 Bernadett Kiss. All rights reserved.
//

import Foundation
import MapKit
import CoreData

class DataController {
    
    let persistentContainer: NSPersistentContainer
    
    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    init(modelName: String) {
        persistentContainer = NSPersistentContainer(name: modelName)
    }
    
    func load(completion: (() -> Void)? = nil) {
        persistentContainer.loadPersistentStores { (storeDescription, error) in
            guard error == nil else {
                fatalError(error!.localizedDescription)
            }
            completion?()
        }
    }
    
    func fetchAllPins() -> [Pin]? {
        let fetchRequest: NSFetchRequest<Pin> = Pin.fetchRequest()
        if let pins = try? viewContext.fetch(fetchRequest) {
            return pins
        } else {
            return nil
        }
    }
    
    func fetchPin(atCoordinate coordinate: CLLocationCoordinate2D) -> Pin? {
        let latitude = String(coordinate.latitude)
        let longitude = String(coordinate.longitude)
        
        let fetchRequest: NSFetchRequest<Pin> = Pin.fetchRequest()
        let latitudePredicate = NSPredicate(format: "latitude = %@", latitude)
        let longitudePredicate = NSPredicate(format: "longitude = %@", longitude)
        let subpredicates: [NSPredicate]
        subpredicates = [latitudePredicate, longitudePredicate]
        let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: subpredicates)
        fetchRequest.predicate = compoundPredicate
        if let result = try? viewContext.fetch(fetchRequest) {
            if !result.isEmpty {
                return result.first
            }
            return nil
        } else {
            return nil
        }
    }
    
    func fetchPhotos(for pin: Pin, completion: @escaping (_ success: Bool) -> Void) {
        deletePhotos(of: pin)
        guard let latitude = pin.latitude, let longitude = pin.longitude else { return }
        if pin.flickrPage == nil {
            FlickrClient.shared.getPhotos(latitude: latitude, longitude: longitude, page: 1) { result in
                print("Downloading the first set")
                if case let .success(pages, parsedPhotos) = result {
                    self.viewContext.perform {
                        let flickrPage = FlickrPage(context: self.viewContext)
                        flickrPage.pin = pin
                        flickrPage.total = Int16(pages)
                        flickrPage.next = 2
                        self.photos(from: parsedPhotos, pin: pin)
                        try? self.viewContext.save()
                        completion(true)
                    }
                }
            }
        }
        if let nextPage = pin.flickrPage?.next, let totalPages = pin.flickrPage?.total {
            print("NextPage: \(nextPage)")
            if nextPage <= totalPages {
                FlickrClient.shared.getPhotos(latitude: latitude, longitude: longitude, page: Int(nextPage)) { result in
                    if case let .success(_, parsedPhotos) = result {
                        self.viewContext.perform {
                            pin.flickrPage?.next = (nextPage < totalPages) ? nextPage + 1 : 1
                            self.photos(from: parsedPhotos, pin: pin)
                            try? self.viewContext.save()
                            completion(true)
                        }
                    }
                }
            }
        }
    }
    
    private func deletePhotos(of pin: Pin) {
        let fetchRequest: NSFetchRequest<Photo> = Photo.fetchRequest()
        let predicate = NSPredicate(format: "pin == %@", pin)
        fetchRequest.predicate = predicate
        
        if let result = try? viewContext.fetch(fetchRequest) {
            for photo in result {
                viewContext.delete(photo)
            }
            try? viewContext.save()
        }
    }
    
    private func photos(from parsedPhotos: [ParsedPhoto], pin: Pin) {
        for parsedPhoto in parsedPhotos {
            let photo = Photo(context: self.viewContext)
            photo.pin = pin
            photo.photoID = parsedPhoto.photoID
            photo.title = parsedPhoto.title
            photo.remoteURL = parsedPhoto.remoteURL as NSURL
        }
    }
}
