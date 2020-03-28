//
//  FlickrClient.swift
//  VirtualTourist
//
//  Created by Omar Mujtaba on 29/3/20.
//  Copyright © 2020 AmmoLogic Training. All rights reserved.
//

import Foundation

class FlickrClient {
    
    // MARK: Define all required Endpoints
    enum Endpoints {
        static let services = "https://www.flickr.com/services/rest"
        static let apiKey = "api_key=ddf6cdae745e021ceec624f47792c27a"
        
        case searchPhotos(String, String)
        case getPhoto(String, String, String, String)
        
        var stringValue: String {
            switch self {
            case .searchPhotos(let lat, let long): return "\(Endpoints.services)/?method=flickr.photos.search&\(Endpoints.apiKey)&lat=\(lat)&lon=\(long)&format=json&nojsoncallback=1"
                case .getPhoto(let farmId, let serverId, let photoId, let photoSecret): return "https://farm\(farmId).staticflickr.com/\(serverId)/\(photoId)_\(photoSecret)_n.jpg"
            }
        }
        
        var url: URL {
            return URL(string: stringValue)!
        }
    }
}
