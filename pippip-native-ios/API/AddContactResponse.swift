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

    static let PENDING = "pending";
    static let ID_NOT_FOUND = "ID not found";
    static let CONTACT_UPDATED = "client updated";

    var error: String?
    var result: String?
    var requestedId: String?
    var directoryId: String?
    var timestamp: Int?
    var version: Double?
    
    required init?(map: Map) {
        if map.JSON["error"] == nil {
            guard let _ = map.JSON["result"] as? String else { return nil }
            guard let _ =  map.JSON["timestamp"] as? Int else { return nil }
            guard let _ = map.JSON["version"] as? Double else { return nil }
            if version != 1.2 {
                return nil
            }
            guard let _ =  map.JSON["requestedId"] as? String else { return nil }
        }
    }

    func mapping(map: Map) {
        error <- map["error"]
        result <- map["result"]
        requestedId <- map["requestedId"]
        directoryId <- map["directoryId"]
        timestamp <- map["timestamp"]
        version <- map["version"];
    }

}
