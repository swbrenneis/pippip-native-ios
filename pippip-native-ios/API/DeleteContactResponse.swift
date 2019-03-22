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
    var publicId: String?
    var result: String?
    var version: Double?

    required init?(map: Map) {
        if map.JSON["error"] == nil {
            guard let _ = map.JSON["publicId"] else { return nil }
            guard let _ = map.JSON["result"] else { return nil }
        }
    }

    required init?(jsonString: String) {
        
    }
    
    func mapping(map: Map) {
        error <- map["error"]
        publicId <- map["publicId"]
        result <- map["result"]
        version <- map["version"]
    }

}
