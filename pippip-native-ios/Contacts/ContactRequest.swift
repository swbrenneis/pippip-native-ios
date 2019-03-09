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
        
    }
    
    init?(request: [String: String]) {
        
        guard let puid = request["publicId"] else { return nil }
        publicId = puid
        directoryId = request["directoryId"]
        
    }
    
    static func ==(lhs: ContactRequest, rhs: ContactRequest) -> Bool {
        return lhs.publicId == rhs.publicId
    }
    
}
