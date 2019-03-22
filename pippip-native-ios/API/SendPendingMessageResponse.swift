//
//  SendPendingMessageResponse.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 3/20/19.
//  Copyright © 2019 seComm. All rights reserved.
//

import Foundation
import ObjectMapper

class SendPendingMessageResponse : Mappable, EnclaveResponseProtocol {

    static let SENT = "sent"
    
    var json: String?
    var result: String?
    var version: Double?
    var timestamp: Int64?
    var error: String?
    
    required init?(map: Map) {
        if map.JSON["error"] == nil {
            guard let _ = map.JSON["result"] else { return nil }
            guard let _ = map.JSON["version"] else { return nil }
            guard let _ = map.JSON["timestamp"] else { return nil }
        }
    }
    
    required init?(jsonString: String) {
        
    }
    
    func mapping(map: Map) {
        result <- map["result"]
        version <- map["version"]
        timestamp <- map["timestamp"]
        error <- map["error"]
    }
    
    
}
