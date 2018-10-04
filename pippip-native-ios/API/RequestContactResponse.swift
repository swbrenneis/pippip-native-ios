//
//  RequestContactResponse.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 6/2/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit
import ObjectMapper

class RequestContactResponse: NSObject, EnclaveResponseProtocol {

    var error: String?
    var result: String?
    var requestedId: String?
    var requestedContactId: String?
    var timestamp: Int?
    var version: Double?
    
    required init?(map: Map) {
        if map.JSON["error"] == nil {
            if map.JSON["result"] == nil {
                return nil
            }
            if map.JSON["timestamp"] == nil {
                return nil
            }
            guard let mversion = map.JSON["version"] as? Double else { return nil }
            if mversion >= 1.1 {
                if map.JSON["requestedId"] == nil {
                    return nil
                }
            }
            else {
                if map.JSON["requestedContactId"] == nil {
                    return nil
                }
            }
        }
    }

    func mapping(map: Map) {
        error <- map["error"]
        result <- map["result"]
        requestedId <- map["requestedId"]
        requestedContactId <- map["requestedContactId"]
        timestamp <- map["timestamp"]
        version <- map["version"];
    }

}
