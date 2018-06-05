//
//  AcknowledgeResponse.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 6/1/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit
import ObjectMapper

class AcknowledgeRequestResponse: NSObject, EnclaveResponseProtocol {
    
    var error: String?
    var acknowledged: ServerContact?

    required init?(map: Map) {
        if map.JSON["error"] == nil && map.JSON["acknowledged"] == nil {
            return nil
        }
    }
    
    func mapping(map: Map) {
        error <- map["error"]
        acknowledged <- map["acknowledged"]
    }

}
