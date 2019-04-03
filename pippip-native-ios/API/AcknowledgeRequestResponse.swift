//
//  AcknowledgeResponse.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 6/1/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit
import ObjectMapper

class AcknowledgeRequestResponse: EnclaveResponseProtocol {

    var json: String?
    var error: String?
    var acknowledged: ServerContact?
    var result: String?
    var version: Double?
    var timestamp: Int64?

    required init?(map: Map) {
        if map.JSON["error"] == nil {
            guard let _ = map.JSON["acknowledged"] else { return nil }
            guard let _ = map.JSON["result"] else { return nil }
        }
        guard let _ = map.JSON["version"] else { return nil }
        guard let _ = map.JSON["timestamp"] else { return nil }
    }
    
    required init?(jsonString: String) {
        
    }
    
    func mapping(map: Map) {
        error <- map["error"]
        acknowledged <- map["acknowledged"]
        version <- map["version"]
        timestamp <- map["timestamp"]
        result <- map["result"]
    }

}
