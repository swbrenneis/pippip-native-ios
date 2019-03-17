//
//  SendMessageResponse.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 6/2/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit
import ObjectMapper

class SendMessageResponse: EnclaveResponseProtocol {

    var json: String?
    var error: String?
    var result: String?
    var publicId: String?
    var sequence: Int?
    var timestamp: Int?
    var version: Float?

    required init?(map: Map) {
        if map.JSON["error"] == nil {
            guard let _ = map.JSON["result"] else { return nil }
            guard let _ = map.JSON["publicId"] else { return nil }
            guard let _ = map.JSON["sequence"]  else { return nil }
            guard let _ = map.JSON["timestamp"]  else { return nil }
        }
    }

    required init?(jsonString: String) {
        
    }
    
    func mapping(map: Map) {
        error <- map["error"]
        result <- map["result"]
        publicId <- map["publicId"]
        sequence <- map["sequence"]
        timestamp <- map["timestamp"]
        version <- map["version"]
    }

}
