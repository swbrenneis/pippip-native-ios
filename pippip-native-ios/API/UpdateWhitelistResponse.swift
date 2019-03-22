//
//  UpdateWhitelistResponse.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 6/1/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit
import ObjectMapper

class UpdateWhitelistResponse: EnclaveResponseProtocol {

    var json: String?
    var error: String?
    var id: String?
    var result: String?
    var action: String?
    var version: Double?

    required init?(map: Map) {
        if map.JSON["error"] == nil {
            guard let _ = map.JSON["id"] else { return nil }
            guard let _ = map.JSON["result"] else { return nil }
            guard let _ = map.JSON["action"] else { return nil }
        }
    }
    
    required init?(jsonString: String) {
    }
    
    
    func mapping(map: Map) {
        error <- map["error"]
        id <- map["id"]
        result <- map["result"]
        action <- map["action"]
        version <- map["version"]
    }

}
