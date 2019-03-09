//
//  PostError.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 3/4/19.
//  Copyright © 2019 seComm. All rights reserved.
//

import Foundation

enum PostError : Error {
    case sessionNotActive
    case invalidResource
    case invalidServerResponse
}

extension PostError : LocalizedError {
    
    var errorDescription: String? {
        switch self {
        case .sessionNotActive:
            return NSLocalizedString("Session not active", comment: "")
        case .invalidResource:
            return NSLocalizedString("Invalid post resource", comment: "")
        case .invalidServerResponse:
            return NSLocalizedString("Invalid server response", comment: "")
        }
    }

}
