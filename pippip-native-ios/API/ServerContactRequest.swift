//
//  ServerContactRequest.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 3/26/19.
//  Copyright © 2019 seComm. All rights reserved.
//

import Foundation
import ObjectMapper

class ServerContactRequest : Mappable {
    
    var requestingId: String?
    var requestingDirectoryId: String?
    var requestedId: String?
    var initialMessage: Bool?
    var version: Float?
    
    required init?(map: Map) {
        guard let _ = map.JSON["requestingId"] as? String else { return nil }
        guard let _ = map.JSON["requestedId"] as? String else { return nil }
        guard let _ = map.JSON["requestingDirectoryId"] as? String else { return nil }
        guard let _ = map.JSON["initialMessage"] as? Bool else { return nil }
        guard let _ = map.JSON["version"] as? Float else { return nil }
    }
    
    func mapping(map: Map) {
        requestingId <- map["requestingId"]
        requestedId <- map["requestedId"]
        requestingDirectoryId <- map["requestingDirectoryId"]
        initialMessage <- map["initialMessage"]
        version <- map["version"]
    }
    
}
