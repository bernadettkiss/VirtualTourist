//
//  FlickrClient.swift
//  VirtualTourist
//
//  Created by Bernadett Kiss on 7/23/18.
//  Copyright © 2018 Bernadett Kiss. All rights reserved.
//

import UIKit

typealias Parameters = [String: String]

enum Result {
    case success(pages: Int, photos: [ParsedPhoto])
    case failure
}

struct ParsedPhoto {
    let photoID: String
    let title: String
    let remoteURL: URL
}

class FlickrClient {
    
    static let shared = FlickrClient()
    
    func getPhotos(latitude: Double, longitude: Double, page: Int, completion: @escaping (Result) -> Void) {
        if verifyCoordinate(latitude: latitude, longitude: longitude) {
            let urlParameters = flickrURLParameters(latitude: latitude, longitude: longitude, page: page)
            NetworkManager.shared.GET(url: flickrURL(parameters: urlParameters)) { networkResponse in
                switch networkResponse {
                case .failure(error: let error):
                    debugPrint(error)
                    completion(.failure)
                    return
                case .success(response: let result):
                    let parsedResult = self.process(result as! JSONObject)
                    let pages = parsedResult.0
                    let parsedPhotos = parsedResult.1
                    if let pages = pages, let parsedPhotos = parsedPhotos {
                        completion(Result.success(pages: pages, photos: parsedPhotos))
                    } else {
                        completion(.failure)
                    }
                }
            }
        }
    }
    
    private func verifyCoordinate(latitude: Double, longitude: Double) -> Bool {
        if latitude > Constants.SearchLatRange.0 && latitude < Constants.SearchLatRange.1 && longitude > Constants.SearchLonRange.0 && longitude < Constants.SearchLonRange.1 {
            return true
        } else {
            return false
        }
    }
    
    private func flickrURLParameters(latitude: Double, longitude: Double, page: Int) -> Parameters {
        let urlParameters = [
            ParameterKeys.Method: ParameterValues.SearchMethod,
            ParameterKeys.APIKey: ParameterValues.APIKey,
            ParameterKeys.BoundingBox: boundingBoxString(latitude: latitude, longitude: longitude),
            ParameterKeys.SafeSearch: ParameterValues.UseSafeSearch,
            ParameterKeys.Extras: ParameterValues.MediumURL,
            ParameterKeys.Format: ParameterValues.ResponseFormat,
            ParameterKeys.NoJSONCallback: ParameterValues.DisableJSONCallback,
            ParameterKeys.PerPage: ParameterValues.PerPage,
            ParameterKeys.Page: "\(page)"
        ]
        return urlParameters
    }
    
    private func boundingBoxString(latitude: Double, longitude: Double) -> String {
        let minimumLon = max(longitude - FlickrClient.Constants.SearchBBoxHalfWidth, FlickrClient.Constants.SearchLonRange.0)
        let minimumLat = max(latitude - FlickrClient.Constants.SearchBBoxHalfHeight, FlickrClient.Constants.SearchLatRange.0)
        let maximumLon = min(longitude + FlickrClient.Constants.SearchBBoxHalfWidth, FlickrClient.Constants.SearchLonRange.1)
        let maximumLat = min(latitude + FlickrClient.Constants.SearchBBoxHalfHeight, FlickrClient.Constants.SearchLatRange.1)
        return "\(minimumLon),\(minimumLat),\(maximumLon),\(maximumLat)"
    }
    
    private func flickrURL(parameters: Parameters) -> URL {
        var components = URLComponents()
        components.scheme = Constants.ApiScheme
        components.host = Constants.ApiHost
        components.path = Constants.ApiPath
        
        var queryItems = [URLQueryItem]()
        for (key, value) in parameters {
            let queryItem = URLQueryItem(name: key, value: value)
            queryItems.append(queryItem)
        }
        components.queryItems = queryItems
        return components.url!
    }
    
    private func process(_ result: JSONObject) -> (Int?, [ParsedPhoto]?) {
        guard let status = result[ResponseKeys.Status] as? String, status == ResponseValues.OKStatus,
            let photosDictionary = result[ResponseKeys.Photos] as? [String: AnyObject], let photoArray = photosDictionary[ResponseKeys.Photo] as? [[String: AnyObject]],
            let pages = photosDictionary[ResponseKeys.Pages] as? Int else {
                return (nil, nil)
        }
        var parsedPhotos = [ParsedPhoto]()
        for photoJSON in photoArray {
            if let parsedPhoto = self.photo(fromJSON: photoJSON) {
                parsedPhotos.append(parsedPhoto)
            }
        }
        return (pages, parsedPhotos)
    }
    
    private func photo(fromJSON json: [String: AnyObject]) -> ParsedPhoto? {
        guard let photoID = json[ResponseKeys.Id] as? String,
            let title = json[ResponseKeys.Title] as? String,
            let remoteURLString = json[ResponseKeys.MediumURL] as? String,
            let remoteURL = URL(string: remoteURLString) else {
                return nil
        }
        return ParsedPhoto(photoID: photoID, title: title, remoteURL: remoteURL)
    }
}
