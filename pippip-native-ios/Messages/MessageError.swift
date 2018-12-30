//
//  MessageError.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 12/30/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import Foundation

enum MessageError: Error {
    case invalidContactId
}

extension MessageError: LocalizedError {
    
    var errorDescription: String? {
        switch self {
        case .invalidContactId:
            return NSLocalizedString("Invalid contact ID", comment: "")
        }
    }
    
}
