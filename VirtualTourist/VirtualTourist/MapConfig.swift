//
//  MapConfig.swift
//  VirtualTourist
//
//  Created by Bernadett Kiss on 7/27/18.
//  Copyright © 2018 Bernadett Kiss. All rights reserved.
//

import Foundation
import MapKit

class MapConfig {
    
    static let shared = MapConfig()
    
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
        UserDefaults.standard.set(centerCoordinateLatitude, forKey: MapConfigProperties.centerCoordinateLatitude.rawValue)
        UserDefaults.standard.set(centerCoordinateLongitude, forKey: MapConfigProperties.centerCoordinateLongitude.rawValue)
        UserDefaults.standard.set(latitudeDelta, forKey: MapConfigProperties.latitudeDelta.rawValue)
        UserDefaults.standard.set(longitudeDelta, forKey: MapConfigProperties.longitudeDelta.rawValue)
    }
    
    func load() -> MKCoordinateRegion? {
        if let latitudeString = UserDefaults.standard.string(forKey: MapConfigProperties.centerCoordinateLatitude.rawValue),
            let longitudeString = UserDefaults.standard.string(forKey: MapConfigProperties.centerCoordinateLongitude.rawValue),
            let latitudeDeltaString = UserDefaults.standard.string(forKey: MapConfigProperties.latitudeDelta.rawValue),
            let longitudeDeltaString = UserDefaults.standard.string(forKey: MapConfigProperties.longitudeDelta.rawValue) {
            
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
