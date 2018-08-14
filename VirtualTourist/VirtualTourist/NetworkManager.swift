//
//  NetworkManager.swift
//  VirtualTourist
//
//  Created by Bernadett Kiss on 7/27/18.
//  Copyright © 2018 Bernadett Kiss. All rights reserved.
//

import Foundation

typealias JSONObject = [String: AnyObject]

enum NetworkResponse {
    case success(response: Any)
    case failure(error: NSError)
}

class NetworkManager {
    
    static let shared = NetworkManager()
    
    var session = URLSession.shared
    
    func GET(url: URL, completionHandler: @escaping (_ networkResponse: NetworkResponse) -> Void) {
        let request = URLRequest(url: url)
        let task = session.dataTask(with: request) { (data, response, error) in
            
            guard error == nil else {
                let error = NetworkResponse.failure(error: error! as NSError)
                completionHandler(error)
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                let error = NetworkResponse.failure(error: NSError(domain: "GETRequest", code: 1, userInfo: [NSLocalizedDescriptionKey: "Request returned a status code other than 2xx"]))
                completionHandler(error)
                return
            }
            
            guard let jsonData = data else {
                let error = NetworkResponse.failure(error: NSError(domain: "GETRequest", code: 1, userInfo: [NSLocalizedDescriptionKey: "No data was returned by the request"]))
                completionHandler(error)
                return
            }
            
            do {
                let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: .allowFragments) as! JSONObject
                completionHandler(NetworkResponse.success(response: jsonObject))
            } catch {
                completionHandler(NetworkResponse.failure(error: error as NSError))
            }
        }
        task.resume()
    }
    
    func downloadImage(imageURL: URL, completionHandler: @escaping (_ networkResponse: NetworkResponse) -> Void) {
        let request = URLRequest(url: imageURL)
        let task = session.dataTask(with: request) { (data, response, error) in
            guard error == nil else {
                let error = NetworkResponse.failure(error: error! as NSError)
                completionHandler(error)
                return
            }
            
            guard let imageData = data else {
                let error = NetworkResponse.failure(error: NSError(domain: "downloadImage", code: 1, userInfo: [NSLocalizedDescriptionKey: "No data was returned by the request"]))
                completionHandler(error)
                return
            }
            completionHandler(NetworkResponse.success(response: imageData))
        }
        task.resume()
    }
}
