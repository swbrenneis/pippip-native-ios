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
    var requestingId: String
    var requestedId: String
    var hashValue: Int {
        return requestingId.hashValue
    }
    var displayId: String {
        if directoryId != nil {
            return directoryId!
        }
        else {
            return requestingId
        }
    }
    
    var sessionState = SessionState()
    

    init(publicId: String, directoryId: String?) {
        
        self.requestingId = publicId
        self.directoryId = directoryId
        requestedId = ""
        
    }

    init?(request: ServerContactRequest) {
        
        guard let puid = request.requestingId else { return nil }
        requestingId = puid
        directoryId = request.requestingDirectoryId
        guard let rqid = request.requestedId else { return nil }
        requestedId = rqid
        if requestedId != sessionState.publicId! {
            return nil
        }
        
    }
    
    static func ==(lhs: ContactRequest, rhs: ContactRequest) -> Bool {
        return lhs.requestingId == rhs.requestingId
    }
    
}
