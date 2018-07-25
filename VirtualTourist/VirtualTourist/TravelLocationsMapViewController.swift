//
//  TravelLocationsMapViewController.swift
//  VirtualTourist
//
//  Created by Bernadett Kiss on 7/16/18.
//  Copyright © 2018 Bernadett Kiss. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class TravelLocationsMapViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var instructionView: UIView!
    @IBOutlet weak var instructionLabel: UILabel!
    
    var dataController: DataController!
    var selectedPin: Pin?
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = editButtonItem
        mapView.delegate = self
        mapView.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:))))
        
        if let pins = retrievePinsFromPersistentStore() {
            createAnnotations(for: pins)
        }
    }
    
    // MARK: - Methods
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        
        if editing {
            instructionView.backgroundColor = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
            instructionLabel.text = "Tap pins to delete"
        } else {
            instructionView.backgroundColor = #colorLiteral(red: 0.3333333433, green: 0.3333333433, blue: 0.3333333433, alpha: 1)
            instructionLabel.text = "Long-press on the map to drop a pin"
        }
    }
    
    @objc func handleLongPress(_ sender: UILongPressGestureRecognizer) {
        guard !isEditing else { return }
        
        if sender.state == .began {
            let touchPoint = sender.location(in: mapView)
            let coordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
            let newPin = addPin(atCoordinate: coordinate)
            createAnnotation(for: newPin)
        }
    }
    
    func retrievePinsFromPersistentStore() -> [Pin]? {
        let fetchRequest: NSFetchRequest<Pin> = Pin.fetchRequest()
        
        if let result = try? dataController.viewContext.fetch(fetchRequest) {
            return result
        } else {
            return nil
        }
    }
    
    func retrievePinFromPersistentStore(atCoordinate coordinate: CLLocationCoordinate2D) -> Pin? {
        let latitude = String(coordinate.latitude)
        let longitude = String(coordinate.longitude)
        
        let fetchRequest: NSFetchRequest<Pin> = Pin.fetchRequest()
        let latitudePredicate = NSPredicate(format: "latitude = %@", latitude)
        let longitudePredicate = NSPredicate(format: "longitude = %@", longitude)
        let subpredicates: [NSPredicate]
        subpredicates = [latitudePredicate, longitudePredicate]
        let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: subpredicates)
        fetchRequest.predicate = compoundPredicate
        if let result = try? dataController.viewContext.fetch(fetchRequest) {
            if !result.isEmpty {
                return result[0]
            }
            return nil
        } else {
            return nil
        }
    }
    
    func addPin(atCoordinate coordinate: CLLocationCoordinate2D) -> Pin {
        let pin = Pin(context: dataController.viewContext)
        pin.latitude = String(coordinate.latitude)
        pin.longitude = String(coordinate.longitude)
        try? dataController.viewContext.save()
        return pin
    }
    
    func remove(pin: Pin) {
        dataController.viewContext.delete(pin)
        try? dataController.viewContext.save()
    }
    
    func createAnnotations(for pins: [Pin]) {
        for pin in pins {
            createAnnotation(for: pin)
        }
        mapView.showAnnotations(mapView.annotations, animated: true)
    }
    
    func createAnnotation(for pin: Pin) {
        let latitude = CLLocationDegrees(pin.latitude!)
        let longitude = CLLocationDegrees(pin.longitude!)
        let coordinate = CLLocationCoordinate2D(latitude: latitude!, longitude: longitude!)
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        mapView.addAnnotation(annotation)
    }
    
    // MARK: - MKMapViewDelegate Methods
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let annotation = view.annotation else { return }
        
        if let selectedPin = retrievePinFromPersistentStore(atCoordinate: annotation.coordinate) {
            if isEditing {
                remove(pin: selectedPin)
                mapView.removeAnnotation(annotation)
            } else {
                self.selectedPin = selectedPin
                performSegue(withIdentifier: "toPhotoAlbum", sender: nil)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toPhotoAlbum" {
            guard let photoAlbumViewController = segue.destination as? PhotoAlbumViewController else { return }
            photoAlbumViewController.selectedPin = selectedPin!
        }
    }
}
