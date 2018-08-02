//
//  NetworkManager.swift
//  VirtualTourist
//
//  Created by Bernadett Kiss on 7/27/18.
//  Copyright © 2018 Bernadett Kiss. All rights reserved.
//

import Foundation

typealias Parameters = [String: String]
typealias CompletionHandler = (_ result: [String: AnyObject]?, _ error: NSError?) -> ()

class NetworkManager {
    
    static let shared = NetworkManager()
    
    var session = URLSession.shared
    
    func GETRequest(urlParameters: Parameters, completionHandler: @escaping CompletionHandler) {
        let url = buildFlickrURL(fromParameters: urlParameters)
        let request = URLRequest(url: url)
        let _ = createTask(with: request) { (results, error) in
            completionHandler(results, error)
            return
        }
    }
    
    private func buildFlickrURL(fromParameters parameters: Parameters) -> URL {
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
    
    private func createTask(with request: URLRequest, completionHandler: @escaping CompletionHandler) -> URLSessionDataTask {
        let task = session.dataTask(with: request) { (data, response, error) in
            
            guard error == nil else {
                completionHandler(nil, error! as NSError)
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                let error = "Your request returned a status code other than 2xx!"
                completionHandler(nil, NSError(domain: "createTask", code: 1, userInfo: [NSLocalizedDescriptionKey: error]))
                return
            }
            
            guard let data = data else {
                let error = "No data was returned by the request!"
                completionHandler(nil, NSError(domain: "createTask", code: 1, userInfo: [NSLocalizedDescriptionKey: error]))
                return
            }
            
            self.convertData(data, completionHandler: completionHandler)
        }
        task.resume()
        return task
    }
    
    private func convertData(_ data: Data, completionHandler: CompletionHandler) {
        let parsedResult: [String: AnyObject]!
        do {
            parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: AnyObject]
            completionHandler(parsedResult, nil)
        } catch {
            completionHandler(nil, error as NSError)
        }
    }
}
