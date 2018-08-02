//
//  FlickrClientConstants.swift
//  VirtualTourist
//
//  Created by Bernadett Kiss on 7/23/18.
//  Copyright © 2018 Bernadett Kiss. All rights reserved.
//

import Foundation

extension FlickrClient {
    
    struct Constants {
        static let ApiScheme = "https"
        static let ApiHost = "api.flickr.com"
        static let ApiPath = "/services/rest"
        static let SearchBBoxHalfWidth = 1.0
        static let SearchBBoxHalfHeight = 1.0
        static let SearchLatRange = (-90.0, 90.0)
        static let SearchLonRange = (-180.0, 180.0)
    }
    
    struct ParameterKeys {
        static let Method = "method"
        static let APIKey = "api_key"
        static let BoundingBox = "bbox"
        static let SafeSearch = "safe_search"
        static let Extras = "extras"
        static let Format = "format"
        static let NoJSONCallback = "nojsoncallback"
        static let PerPage = "per_page"
        static let Page = "page"
    }
    
    struct ParameterValues {
        static let SearchMethod = "flickr.photos.search"
        static let APIKey = myFlickrApiKey
        static let UseSafeSearch = "1"
        static let MediumURL = "url_m"
        static let ResponseFormat = "json"
        static let DisableJSONCallback = "1"
        static let PerPage = "21"
    }
    
    struct ResponseKeys {
        static let Status = "stat"
        static let Photos = "photos"
        static let Pages = "pages"
        static let Photo = "photo"
        static let Id = "id"
        static let Title = "title"
        static let MediumURL = "url_m"
        static let Total = "total"
    }
    
    struct ResponseValues {
        static let OKStatus = "ok"
    }
}
