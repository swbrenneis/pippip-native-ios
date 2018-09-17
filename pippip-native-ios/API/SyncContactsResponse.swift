//
//  SyncContactsResponse.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 9/15/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit
import ObjectMapper

class SyncContactsResponse: NSObject, EnclaveResponseProtocol {
    
    var error: String?
    var responses: [SyncResponse]?

    required init?(map: Map) {

        if map.JSON["error"] == nil && map.JSON["responses"] == nil {
            return nil
        }

    }
    
    func mapping(map: Map) {

        error <- map["error"]
        responses <- map["responses"]

    }
    
}
