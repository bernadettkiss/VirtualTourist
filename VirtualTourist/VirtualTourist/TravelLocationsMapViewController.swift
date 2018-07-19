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
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = editButtonItem
        
        let fetchRequest: NSFetchRequest<Pin> = Pin.fetchRequest()
        if let result = try? dataController.viewContext.fetch(fetchRequest) {
            createAnnotations(for: result)
        }
        
        mapView.delegate = self
        
        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        mapView.addGestureRecognizer(longPressGestureRecognizer)
    }
    
    // MARK: - Actions
    
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
        if sender.state == .ended {
            let touchPoint = sender.location(in: mapView)
            let coordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
            addPin(atCoordinate: coordinate)
        }
    }
    
    func addPin(atCoordinate coordinate: CLLocationCoordinate2D) {
        let pin = Pin(context: dataController.viewContext)
        pin.latitude = String(coordinate.latitude)
        pin.longitude = String(coordinate.longitude)
        try? dataController.viewContext.save()
        createAnnotation(for: pin)
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
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let annotation = view.annotation else {
            return
        }
        let latitude = String(annotation.coordinate.latitude)
        let longitude = String(annotation.coordinate.longitude)
        
        if isEditing {
            let fetchRequest: NSFetchRequest<Pin> = Pin.fetchRequest()
            let latitudePredicate = NSPredicate(format: "latitude = %@", latitude)
            let longitudePredicate = NSPredicate(format: "longitude = %@", longitude)
            let subpredicates: [NSPredicate]
            subpredicates = [latitudePredicate, longitudePredicate]
            let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: subpredicates)
            fetchRequest.predicate = compoundPredicate
            if let result = try? dataController.viewContext.fetch(fetchRequest) {
                if !result.isEmpty {
                    let pinToDelete = result[0]
                    dataController.viewContext.delete(pinToDelete)
                    try? dataController.viewContext.save()
                }
            }
            mapView.removeAnnotation(annotation)
        }
    }
}
