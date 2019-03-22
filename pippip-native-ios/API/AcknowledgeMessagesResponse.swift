//
//  AcknowledgeMessagesResponse.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 6/2/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit
import ObjectMapper

class AcknowledgeMessagesResponse: NSObject, EnclaveResponseProtocol {

    var json: String?
    var error: String?
    var exceptions: [Triplet]?
    var version: Double?

    required init?(map: Map) {
        if map.JSON["error"] == nil {
            guard let _ = map.JSON["exceptions"] else { return nil }
        }
    }

    required init?(jsonString: String) {
        
    }
    
    func mapping(map: Map) {
        error <- map["error"]
        exceptions <- map["exceptions"]
        version <- map["version"]
    }

}
