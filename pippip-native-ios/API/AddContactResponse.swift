//
//  RequestContactResponse.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 6/2/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit
import ObjectMapper

class AddContactResponse: EnclaveResponseProtocol {

    static let PENDING = "pending";
    static let ID_NOT_FOUND = "ID not found";
    static let CONTACT_UPDATED = "client updated";

    var json: String?
    var error: String?
    var result: String?
    var contact: ServerContact?
    var timestamp: Int?
    var version: Float?
    
    required init?(map: Map) {
        if map.JSON["error"] == nil {
            guard let _ = map.JSON["result"] as? String else { return nil }
            guard let _ =  map.JSON["timestamp"] as? Int else { return nil }
            guard let _ = map.JSON["version"] as? Double else { return nil }
        }
    }

    required init?(jsonString: String) {
    }
    
    func mapping(map: Map) {
        error <- map["error"]
        result <- map["result"]
        contact <- map["contact"]
        timestamp <- map["timestamp"]
        version <- map["version"];
    }

}
