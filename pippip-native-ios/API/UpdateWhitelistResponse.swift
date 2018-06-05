//
//  UpdateWhitelistResponse.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 6/1/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit
import ObjectMapper

class UpdateWhitelistResponse: NSObject, EnclaveResponseProtocol {
    
    var error: String?
    var id: String?
    var result: String?
    var action: String?
    
    required init?(map: Map) {
        if map.JSON["error"] == nil {
            if map.JSON["id"] == nil {
                return nil
            }
            if map.JSON["result"] == nil {
                return nil
            }
            if map.JSON["action"] == nil {
                return nil
            }
        }
    }
    
    func mapping(map: Map) {
        error <- map["error"]
        id <- map["id"]
        result <- map["result"]
        action <- map["action"]
    }

}
