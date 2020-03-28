//
//  ErrorResponse.swift
//  VirtualTourist
//
//  Created by Omar Mujtaba on 29/3/20.
//  Copyright © 2020 AmmoLogic Training. All rights reserved.
//

import Foundation

struct ErrorResponse: Codable {
    let statusCode: Int
    let statusMessage: String
    
    enum CodingKeys: String, CodingKey {
        case statusCode = "code"
        case statusMessage = "message"
    }
}

extension ErrorResponse: LocalizedError {
    var errorDescription: String? {
        return statusMessage
    }
}
