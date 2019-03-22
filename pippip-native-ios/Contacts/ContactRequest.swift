//
//  ContactRequest.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 2/27/19.
//  Copyright © 2019 seComm. All rights reserved.
//

import Foundation

struct ContactRequest: Hashable {
    
    var directoryId: String?
    var publicId: String
    var initialMessage: Bool
    var hashValue: Int {
        return publicId.hashValue
    }
    var displayId: String {
        if directoryId != nil {
            return directoryId!
        }
        else {
            return publicId
        }
    }
    
    init(publicId: String, directoryId: String?) {
        
        self.publicId = publicId
        self.directoryId = directoryId
        self.initialMessage = false

    }
    
    init?(request: ServerContactRequest) {
        
        publicId = request.requestingId!
        directoryId = request.requestingDirectoryId
        initialMessage = request.initialMessage!

    }
    
    static func ==(lhs: ContactRequest, rhs: ContactRequest) -> Bool {
        return lhs.publicId == rhs.publicId
    }
    
}
