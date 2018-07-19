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
    
    var dataController: DataController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let fetchRequest: NSFetchRequest<Pin> = Pin.fetchRequest()
        if let result = try? dataController.viewContext.fetch(fetchRequest) {
            createAnnotations(for: result)
        }
        
        mapView.delegate = self
        
        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        mapView.addGestureRecognizer(longPressGestureRecognizer)
    }
    
    @objc func handleLongPress(_ sender: UILongPressGestureRecognizer) {
        if sender.state == .ended {
            let touchPoint = sender.location(in: mapView)
            let coordinates = mapView.convert(touchPoint, toCoordinateFrom: mapView)
            addPin(atCoordinates: coordinates)
        }
    }
    
    func addPin(atCoordinates coordinates: CLLocationCoordinate2D) {
        let pin = Pin(context: dataController.viewContext)
        pin.latitude = coordinates.latitude
        pin.longitude = coordinates.longitude
        try? dataController.viewContext.save()
        createAnnotation(for: pin)
    }
    
    func createAnnotations(for pins: [Pin]) {
        for pin in pins {
            createAnnotation(for: pin)
        }
    }
    
    func createAnnotation(for pin: Pin) {
        let coordinates = CLLocationCoordinate2D(latitude: CLLocationDegrees(pin.latitude), longitude: CLLocationDegrees(pin.longitude))
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinates
        mapView.addAnnotation(annotation)
        mapView.reloadInputViews()
    }
}
