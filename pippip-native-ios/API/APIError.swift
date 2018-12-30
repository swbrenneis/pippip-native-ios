//
//  APIError.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 12/26/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import Foundation

enum APIError: Error {
    case illegalState
    case invalidResource
    case invalidServerRespopnse
}

extension APIError: LocalizedError {

    var errorDescription: String? {
        switch self {
        case .illegalState:
            return NSLocalizedString("Illegal session state", comment: "")
        case .invalidResource:
            return NSLocalizedString("Invalid URL", comment: "")
        case .invalidServerRespopnse:
            return NSLocalizedString("Invalid response from server", comment: "")
        }
    }
    
}
