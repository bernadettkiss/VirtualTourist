//
//  MapRegion.swift
//  VirtualTourist
//
//  Created by Bernadett Kiss on 7/27/18.
//  Copyright © 2018 Bernadett Kiss. All rights reserved.
//

import Foundation
import MapKit

enum MapRegionProperties: String {
    case centerCoordinateLatitude = "centerCoordinateLatitude"
    case centerCoordinateLongitude = "centerCoordinateLongitude"
    case latitudeDelta = "latitudeDelta"
    case longitudeDelta = "longitudeDelta"
}

class MapRegion {
    
    static let shared = MapRegion()
    
    var centerCoordinateLatitude: String?
    var centerCoordinateLongitude: String?
    var latitudeDelta: String?
    var longitudeDelta: String?
    
    func update(centerCoordinate: CLLocationCoordinate2D, span: MKCoordinateSpan) {
        centerCoordinateLatitude = String(centerCoordinate.latitude)
        centerCoordinateLongitude = String(centerCoordinate.longitude)
        latitudeDelta = String(span.latitudeDelta)
        longitudeDelta = String(span.longitudeDelta)
    }
    
    func save() {
        UserDefaults.standard.set(centerCoordinateLatitude, forKey: MapRegionProperties.centerCoordinateLatitude.rawValue)
        UserDefaults.standard.set(centerCoordinateLongitude, forKey: MapRegionProperties.centerCoordinateLongitude.rawValue)
        UserDefaults.standard.set(latitudeDelta, forKey: MapRegionProperties.latitudeDelta.rawValue)
        UserDefaults.standard.set(longitudeDelta, forKey: MapRegionProperties.longitudeDelta.rawValue)
    }
    
    func load() -> MKCoordinateRegion? {
        if let latitudeString = UserDefaults.standard.string(forKey: MapRegionProperties.centerCoordinateLatitude.rawValue),
            let longitudeString = UserDefaults.standard.string(forKey: MapRegionProperties.centerCoordinateLongitude.rawValue),
            let latitudeDeltaString = UserDefaults.standard.string(forKey: MapRegionProperties.latitudeDelta.rawValue),
            let longitudeDeltaString = UserDefaults.standard.string(forKey: MapRegionProperties.longitudeDelta.rawValue) {
            
            var centerCoordinate = CLLocationCoordinate2D()
            centerCoordinate.latitude = CLLocationDegrees(latitudeString)!
            centerCoordinate.longitude = CLLocationDegrees(longitudeString)!
            
            let latitudeDelta = CLLocationDistance(latitudeDeltaString)!
            let longitudeDelta = CLLocationDistance(longitudeDeltaString)!
            
            let coordinateRegion = MKCoordinateRegion(center: centerCoordinate, span: MKCoordinateSpan(latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta))
            return coordinateRegion
        } else {
            return nil
        }
    }
}
