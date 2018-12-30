//
//  WhitelistError.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 12/28/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import Foundation

enum WhitelistError: Error {
    case idExists
}

extension WhitelistError: LocalizedError {
    
    var errorDescription: String? {
        switch self {
        case .idExists:
            return NSLocalizedString("Duplicate whitelist ID", comment: "")
        }
    }
}
