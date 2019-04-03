//
//  SetContactPolicyResponse.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 6/2/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit
import ObjectMapper

class SetContactPolicyResponse: EnclaveResponseProtocol {

    var json: String?
    var error: String?
    var policy: String?
    var result: String?
    var version: Double?
    var timestamp: Int64?

    required init?(map: Map) {
        if map.JSON["error"] == nil {
            if map.JSON["policy"] == nil {
                return nil
            }
            if map.JSON["result"] == nil {
                return nil
            }
        }
    }

    required init?(jsonString: String) {
        
    }
    
    func mapping(map: Map) {
        error <- map["error"]
        policy <- map["policy"]
        result <- map["result"]
        version <- map["version"]
    }

}
