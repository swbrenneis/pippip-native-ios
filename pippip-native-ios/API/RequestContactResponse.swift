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
    var requestedContactId: String?
    var timestamp: Int?
    
    required init?(map: Map) {
        if map.JSON["error"] == nil {
            if map.JSON["result"] == nil {
                return nil
            }
            if map.JSON["requestedContactId"] == nil {
                return nil
            }
            if map.JSON["timestamp"] == nil {
                return nil
            }
        }
    }

    func mapping(map: Map) {
        error <- map["error"]
        result <- map["result"]
        requestedContactId <- map["requestedContactId"]
        timestamp <- map["timestamp"]
    }

}
