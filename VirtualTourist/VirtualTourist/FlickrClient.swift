//
//  FlickrClient.swift
//  VirtualTourist
//
//  Created by Bernadett Kiss on 7/23/18.
//  Copyright © 2018 Bernadett Kiss. All rights reserved.
//

import UIKit

class FlickrClient {
    
    static let shared = FlickrClient()
    
    func getPhotos(latitude: String, longitude: String, page: Int, completion: @escaping (_ pages: Int?, _ photoDictionary: [[String: AnyObject]]?) -> Void) {
        if verifyCoordinate(latitudeString: latitude, longitudeString: longitude) {
            
            let urlParameters = [
                FlickrClient.ParameterKeys.Method: FlickrClient.ParameterValues.SearchMethod,
                FlickrClient.ParameterKeys.APIKey: FlickrClient.ParameterValues.APIKey,
                FlickrClient.ParameterKeys.BoundingBox: boundingBoxString(latitude: latitude, longitude: longitude),
                FlickrClient.ParameterKeys.SafeSearch: FlickrClient.ParameterValues.UseSafeSearch,
                FlickrClient.ParameterKeys.Extras: FlickrClient.ParameterValues.MediumURL,
                FlickrClient.ParameterKeys.Format: FlickrClient.ParameterValues.ResponseFormat,
                FlickrClient.ParameterKeys.NoJSONCallback: FlickrClient.ParameterValues.DisableJSONCallback,
                FlickrClient.ParameterKeys.PerPage: FlickrClient.ParameterValues.PerPage,
                FlickrClient.ParameterKeys.Page: "\(page)"
            ]
            
            NetworkManager.shared.GETRequest(urlParameters: urlParameters) { (results, error) in
                guard error == nil else { return }
                
                if let results = results {
                    guard let status = results[FlickrClient.ResponseKeys.Status] as? String, status == FlickrClient.ResponseValues.OKStatus else { return }
                    
                    guard let photosDictionary = results[FlickrClient.ResponseKeys.Photos] as? [String: AnyObject] else { return }
                    
                    guard let pages = photosDictionary[FlickrClient.ResponseKeys.Pages] as? Int else { return }
                    
                    guard let photos = photosDictionary[FlickrClient.ResponseKeys.Photo] as? [[String: AnyObject]] else { return }
                    
                    completion(pages, photos)
                }
            }
        }
    }
    
    func verifyCoordinate(latitudeString: String, longitudeString: String) -> Bool {
        if let latitude = Double(latitudeString), let longitude = Double(longitudeString) {
            if latitude > FlickrClient.Constants.SearchLatRange.0 && latitude < FlickrClient.Constants.SearchLatRange.1 && longitude > FlickrClient.Constants.SearchLonRange.0 && longitude < FlickrClient.Constants.SearchLonRange.1 {
                return true
            }
        }
        return false
    }
    
    private func boundingBoxString(latitude: String, longitude: String) -> String {
        if let latitude = Double(latitude), let longitude = Double(longitude) {
            let minimumLon = max(longitude - FlickrClient.Constants.SearchBBoxHalfWidth, FlickrClient.Constants.SearchLonRange.0)
            let minimumLat = max(latitude - FlickrClient.Constants.SearchBBoxHalfHeight, FlickrClient.Constants.SearchLatRange.0)
            let maximumLon = min(longitude + FlickrClient.Constants.SearchBBoxHalfWidth, FlickrClient.Constants.SearchLonRange.1)
            let maximumLat = min(latitude + FlickrClient.Constants.SearchBBoxHalfHeight, FlickrClient.Constants.SearchLatRange.1)
            return "\(minimumLon),\(minimumLat),\(maximumLon),\(maximumLat)"
        } else {
            return "0,0,0,0"
        }
    }
}
