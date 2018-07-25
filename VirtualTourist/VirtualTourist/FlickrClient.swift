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
    
    var photos = [UIImage]()
    
    func getPhotos(latitude: String, longitude: String, completion: @escaping (_ success: Bool) -> Void) {
        photos.removeAll()
        if verifyCoordinate(latitudeString: latitude, longitudeString: longitude) {
            
            let methodParameters = [
                FlickrClient.ParameterKeys.Method: FlickrClient.ParameterValues.SearchMethod,
                FlickrClient.ParameterKeys.APIKey: FlickrClient.ParameterValues.APIKey,
                FlickrClient.ParameterKeys.BoundingBox: boundingBoxString(latitude: latitude, longitude: longitude),
                FlickrClient.ParameterKeys.SafeSearch: FlickrClient.ParameterValues.UseSafeSearch,
                FlickrClient.ParameterKeys.Extras: FlickrClient.ParameterValues.MediumURL,
                FlickrClient.ParameterKeys.Format: FlickrClient.ParameterValues.ResponseFormat,
                FlickrClient.ParameterKeys.NoJSONCallback: FlickrClient.ParameterValues.DisableJSONCallback
            ]
            
            let session = URLSession.shared
            let request = URLRequest(url: flickrURL(fromParameters: methodParameters as [String: AnyObject]))
            
            let task = session.dataTask(with: request) { (data, response, error) in
                
                guard (error == nil) else {
                    completion(false)
                    return
                }
                
                guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                    completion(false)
                    return
                }
                
                guard let data = data else {
                    completion(false)
                    return
                }
                
                let parsedResult: [String: AnyObject]!
                do {
                    parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String: AnyObject]
                } catch {
                    completion(false)
                    return
                }
                
                guard let stat = parsedResult[FlickrClient.ResponseKeys.Status] as? String, stat == FlickrClient.ResponseValues.OKStatus else {
                    completion(false)
                    return
                }
                
                guard let photosDictionary = parsedResult[FlickrClient.ResponseKeys.Photos] as? [String: AnyObject] else {
                    completion(false)
                    return
                }
                
                guard let photosArray = photosDictionary[FlickrClient.ResponseKeys.Photo] as? [[String: AnyObject]] else {
                    completion(false)
                    return
                }
                
                if photosArray.count == 0 {
                    completion(false)
                    return
                } else {
                    for index in 0...(photosArray.count - 1) {
                        let photoDictionary = photosArray[index] as [String: AnyObject]
                        guard let imageUrlString = photoDictionary[FlickrClient.ResponseKeys.MediumURL] as? String else {
                            return
                        }
                        let imageURL = URL(string: imageUrlString)
                        if let imageData = try? Data(contentsOf: imageURL!) {
                            self.photos.append(UIImage(data: imageData)!)
                            print(self.photos.count)
                        }
                        completion(true)
                    }
                }
            }
            task.resume()
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
    
    func boundingBoxString(latitude: String, longitude: String) -> String {
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
    
    func flickrURL(fromParameters parameters: [String: AnyObject]) -> URL {
        var components = URLComponents()
        components.scheme = FlickrClient.Constants.ApiScheme
        components.host = FlickrClient.Constants.ApiHost
        components.path = FlickrClient.Constants.ApiPath
        components.queryItems = [URLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        return components.url!
    }
}
