//
//  RequestContactResponse.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 6/2/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit
import ObjectMapper

class AddContactResponse: NSObject, EnclaveResponseProtocol {

    // Result values
    static let PENDING = "pending"
    static let RETRIED = "retried"
    static let ID_NOT_FOUND = "ID not found"
    static let DUPLICATE_REQUEST = "duplicate request"
    static let DUPLICATE_CONTACT = "duplicate contact"

    var error: String?
    var result: String?
    var contact: ServerContact?
    var timestamp: Int?
    var version: Double?
    
    required init?(map: Map) {
        if map.JSON["error"] == nil {
            if map.JSON["result"] == nil {
                return nil
            }
            if map.JSON["timestamp"] == nil {
                return nil
            }
            if map.JSON["version"] == nil {
                return nil
                
            }
            if map.JSON["contact"] == nil {
                return nil
            }
        }
    }

    func mapping(map: Map) {
        error <- map["error"]
        result <- map["result"]
        contact <- map["contact"]
        timestamp <- map["timestamp"]
        version <- map["version"];
    }

}
