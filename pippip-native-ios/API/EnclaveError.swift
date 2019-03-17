//
//  EnclaveError.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 3/10/19.
//  Copyright © 2019 seComm. All rights reserved.
//

import Foundation

enum EnclaveError : Error {
    case needsAuthentication
    case invalidServerResponse
    case cryptoError(error: String)
    case encodingError
}

extension EnclaveError: LocalizedError {

    var errorDescription: String? {
        switch self {
        case .needsAuthentication:
            return NSLocalizedString(Strings.infoNeedsAuth, comment: "")
        case .invalidServerResponse:
            return NSLocalizedString(Strings.errorInvalidResponse, comment: "")
        case .cryptoError:
            return NSLocalizedString("Cryptography error", comment: "")
        case .encodingError:
            return NSLocalizedString("Unable to encode the request", comment: "")
        }
    }

}
