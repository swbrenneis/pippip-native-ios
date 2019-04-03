//
//  MatchDirectoryIdResponse.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 6/2/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit
import ObjectMapper

class MatchDirectoryIdResponse: NSObject, EnclaveResponseProtocol {

    var json: String?
    var error: String?
    var result: String?
    var publicId: String?
    var directoryId: String?
    var version: Double?
    var timestamp: Int64?

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
        publicId <- map["publicId"]
        directoryId <- map["directoryId"]
        version <- map["version"]
    }

}
