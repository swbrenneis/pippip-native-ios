//
//  SetDirectoryIdResponse.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 6/2/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit
import ObjectMapper

class SetDirectoryIdResponse: NSObject, EnclaveResponseProtocol {
    
    var json: String?
    var error: String?
    var result: String?
    var version: Float?

    required init?(map: Map) {
        if map.JSON["error"] == nil && map.JSON["result"] == nil {
            return nil
        }
    }

    required init?(jsonString: String) {
        
    }
    
    func mapping(map: Map) {
        error <- map["error"]
        result <- map["result"]
        version <- map["version"]
    }

}
