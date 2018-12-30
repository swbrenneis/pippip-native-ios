//
//  ContactError.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 10/20/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit

enum ContactError: Error {
    case notFound
    case invalidStatus
    case invalidPublicId
    case duplicateContact
}

extension ContactError: LocalizedError {

    var errorDescription: String? {
        switch self {
        case .notFound:
            return NSLocalizedString("Contact not found", comment: "")
        case .invalidStatus:
            return NSLocalizedString("Invalid contact status", comment: "")
        case .invalidPublicId:
            return NSLocalizedString("Invalid or missing public ID", comment: "")
        case .duplicateContact:
            return NSLocalizedString("Duplicate contact", comment: "")
        }
    }

}
