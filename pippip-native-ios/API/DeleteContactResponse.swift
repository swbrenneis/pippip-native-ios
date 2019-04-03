//
//  DeleteContactResponse.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 6/2/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit
import ObjectMapper

class DeleteContactResponse: EnclaveResponseProtocol {

    var json: String?
    var error: String?
    var requestedId: String?
    var result: String?
    var version: Double?
    var timestamp: Int64?

    required init?(map: Map) {
        if map.JSON["error"] == nil {
            guard let _ = map.JSON["requestedId"] else { return nil }
            guard let _ = map.JSON["result"] else { return nil }
        }
    }

    required init?(jsonString: String) {
        
    }
    
    func mapping(map: Map) {
        error <- map["error"]
        requestedId <- map["requestedId"]
        result <- map["result"]
        version <- map["version"]
    }

}
