//
//  SearchPhotoResponse.swift
//  VirtualTourist
//
//  Created by Omar Mujtaba on 29/3/20.
//  Copyright © 2020 AmmoLogic Training. All rights reserved.
//

import Foundation

struct SearchPhotoResponse: Codable {
    let photos: PhotosResponse
    let stat: String
}
