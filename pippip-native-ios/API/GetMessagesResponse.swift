//
//  GetMessagesResponse.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 6/2/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit
import ObjectMapper

class GetMessagesResponse: EnclaveResponseProtocol {

    var json: String?
    var error: String?
    var messages: [ServerMessage]?
    var rejected: [String]?
    var version: Float?

    required init?(map: Map) {
        if map.JSON["error"] == nil {
            guard let _ = map.JSON["messages"] else { return nil }
            guard let _ = map.JSON["rejected"] else { return nil }
        }
    }

    required init?(jsonString: String) {
        
    }
    
    func mapping(map: Map) {
        error <- map["error"]
        messages <- map["messages"]
        rejected <- map["rejected"]
        version <- map["version"]
    }

}
