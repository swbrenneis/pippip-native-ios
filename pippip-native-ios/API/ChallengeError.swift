//
//  HMACError.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 12/26/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import Foundation

enum ChallengeError: Error {
    case invalidSignature
    case notAuthenticated
}

extension ChallengeError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .invalidSignature:
            return NSLocalizedString("HMAC signature failed to verify", comment: "")
        case .notAuthenticated:
            return NSLocalizedString("HMAC failed to validate", comment: "")
        }
    }
}
