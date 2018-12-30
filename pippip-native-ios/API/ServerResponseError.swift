//
//  EnclaveResponseError.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 12/26/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import Foundation

enum ServerResponseError: Error {
    case invalidAuthentication
    case invalidServerResponse
    case invalidResponseEncoding
}

extension ServerResponseError: LocalizedError {

    var errorDescription: String? {
        switch self {
        case .invalidAuthentication:
            return NSLocalizedString("Invalid authentication tokens", comment: "")
        case .invalidResponseEncoding:
            return NSLocalizedString("Invalid server response encoding", comment: "")
        case .invalidServerResponse:
            return NSLocalizedString("Invalid server response", comment: "")
        }
    }

}

