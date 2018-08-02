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

class TravelLocationsMapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var centerBarButton: UIBarButtonItem!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var instructionView: UIView!
    @IBOutlet weak var instructionLabel: UILabel!
    
    var locationManager = CLLocationManager()
    var dataController: DataController!
    var selectedPin: Pin?
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print((UIApplication.shared.delegate as! AppDelegate).appLaunchedBefore!)
        
        configureNavigationBar()
        
        locationManager.delegate = self
        mapView.delegate = self
        mapView.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:))))
        
        if let pins = retrievePinsFromPersistentStore() {
            createAnnotations(for: pins)
        }
        
        if (UIApplication.shared.delegate as! AppDelegate).appLaunchedBefore! {
            if let region = MapConfig.shared.load() {
                mapView.setRegion(region, animated: true)
            }
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
    
    func configureNavigationBar() {
        navigationItem.rightBarButtonItem = editButtonItem
        if CLLocationManager.locationServicesEnabled() {
            switch CLLocationManager.authorizationStatus() {
            case .denied, .restricted:
                centerBarButton.isEnabled = false
            case .notDetermined:
                locationManager.requestWhenInUseAuthorization()
            default:
                return
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
        downloadPhotos(forPin: pin)
        try? dataController.viewContext.save()
        return pin
    }
    
    func downloadPhotos(forPin pin: Pin) {
        guard let latitude = pin.latitude, let longitude = pin.longitude else { return }
        FlickrClient.shared.getPhotos(latitude: latitude, longitude: longitude, page: 1) { (pages, photos) in
            if let photos = photos {
                for index in 0..<photos.count {
                    let downloadedPhoto = photos[index] as [String: AnyObject]
                    
                    guard let id = downloadedPhoto[FlickrClient.ResponseKeys.Id] as? String else { return }
                    guard let title = downloadedPhoto[FlickrClient.ResponseKeys.Title] as? String else { return }
                    guard let imageURLString = downloadedPhoto[FlickrClient.ResponseKeys.MediumURL] as? String else { return }
                    
                    let photo = Photo(context: self.dataController.viewContext)
                    photo.id = id
                    photo.title = title
                    photo.url = imageURLString
                    photo.pin = pin
                }
            }
            try? self.dataController.viewContext.save()
        }
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SegueIdentifier.toPhotoAlbum.rawValue {
            guard let photoAlbumViewController = segue.destination as? PhotoAlbumViewController else { return }
            photoAlbumViewController.selectedPin = selectedPin!
            photoAlbumViewController.dataController = dataController
        }
    }
    
    // MARK: - MKMapViewDelegate Methods
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        MapConfig.shared.update(centerCoordinate: mapView.region.center, span: mapView.region.span)
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let annotation = view.annotation else { return }
        
        if let selectedPin = retrievePinFromPersistentStore(atCoordinate: annotation.coordinate) {
            if isEditing {
                remove(pin: selectedPin)
                mapView.removeAnnotation(annotation)
            } else {
                self.selectedPin = selectedPin
                performSegue(withIdentifier: SegueIdentifier.toPhotoAlbum.rawValue, sender: nil)
            }
        }
    }
}
