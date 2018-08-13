//
//  TravelLocationsMapViewController.swift
//  VirtualTourist
//
//  Created by Bernadett Kiss on 7/16/18.
//  Copyright © 2018 Bernadett Kiss. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import CoreData

class TravelLocationsMapViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    @IBOutlet weak var centerMapBarButton: UIBarButtonItem!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var instructionView: UIView!
    @IBOutlet weak var instructionLabel: UILabel!
    
    var locationManager = CLLocationManager()
    var dataController: DataController!
    var selectedPin: Pin?
    let segueIdentifier = "toPhotoAlbum"
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureNavigationBar()
        
        locationManager.delegate = self
        mapView.delegate = self
        mapView.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:))))
        
        if let pins = dataController.fetchAllPins() {
            createAnnotations(for: pins)
        }
        
        if (UIApplication.shared.delegate as! AppDelegate).appLaunchedBefore! {
            if let region = MapRegion.shared.load() {
                mapView.setRegion(region, animated: true)
            }
        }
    }
    
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
    
    // MARK: - Actions
    
    @IBAction func centerMapPressed(_ sender: UIBarButtonItem) {
        guard let centerCoordinate = locationManager.location?.coordinate else { return }
        let latitudinalMeters = 10000.0
        let longitudinalMeters = 10000.0
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(centerCoordinate, latitudinalMeters, longitudinalMeters)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    // MARK: - Methods
    
    private func configureNavigationBar() {
        navigationItem.rightBarButtonItem = editButtonItem
        updateCenterMapBarButton()
    }
    
    private func updateCenterMapBarButton() {
        if CLLocationManager.locationServicesEnabled() {
            switch CLLocationManager.authorizationStatus() {
            case .denied, .restricted:
                centerMapBarButton.isEnabled = false
            case .notDetermined:
                locationManager.requestWhenInUseAuthorization()
            default:
                return
            }
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
    
    private func addPin(atCoordinate coordinate: CLLocationCoordinate2D) -> Pin {
        let pin = Pin(context: dataController.viewContext)
        pin.latitude = String(coordinate.latitude)
        pin.longitude = String(coordinate.longitude)
        dataController.fetchPhotos(for: pin) { completion in }
        try? dataController.viewContext.save()
        return pin
    }
    
    private func remove(pin: Pin) {
        dataController.viewContext.delete(pin)
        try? dataController.viewContext.save()
    }
    
    private func createAnnotations(for pins: [Pin]) {
        for pin in pins {
            createAnnotation(for: pin)
        }
        mapView.showAnnotations(mapView.annotations, animated: true)
    }
    
    private func createAnnotation(for pin: Pin) {
        let latitude = CLLocationDegrees(pin.latitude!)
        let longitude = CLLocationDegrees(pin.longitude!)
        let coordinate = CLLocationCoordinate2D(latitude: latitude!, longitude: longitude!)
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        mapView.addAnnotation(annotation)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == segueIdentifier {
            guard let photoAlbumViewController = segue.destination as? PhotoAlbumViewController else { return }
            photoAlbumViewController.selectedPin = selectedPin!
            photoAlbumViewController.dataController = dataController
        }
    }
    
    // MARK: - CLLocationManagerDelegate Methods
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        updateCenterMapBarButton()
    }
    
    // MARK: - MKMapViewDelegate Methods
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        MapRegion.shared.update(centerCoordinate: mapView.region.center, span: mapView.region.span)
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let annotation = view.annotation else { return }
        
        if let selectedPin = dataController.fetchPin(atCoordinate: annotation.coordinate) {
            if isEditing {
                remove(pin: selectedPin)
                mapView.removeAnnotation(annotation)
            } else {
                self.selectedPin = selectedPin
                performSegue(withIdentifier: segueIdentifier, sender: nil)
            }
        }
    }
}
