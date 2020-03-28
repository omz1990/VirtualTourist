//
//  PhotosResponse.swift
//  VirtualTourist
//
//  Created by Omar Mujtaba on 29/3/20.
//  Copyright © 2020 AmmoLogic Training. All rights reserved.
//

import Foundation

struct PhotosResponse: Codable {
    let page: Int
    let pages: String
    let perpage: String
    let total: String
    let photo: [Photo]?
}
