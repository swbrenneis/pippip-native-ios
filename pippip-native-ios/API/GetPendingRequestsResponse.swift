//
//  GetPendingRequestsResponse.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 6/2/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit
import ObjectMapper

class GetPendingRequestsResponse: EnclaveResponseProtocol {

    var json: String?
    var error: String?
    var requests: [[String: String]]?
    var version: Float?

    required init?(map: Map) {
        if map.JSON["error"] == nil {
            guard let _ = map.JSON["requests"] else { return nil }
        }
    }

    required init?(jsonString: String) {
        
    }
    
    func mapping(map: Map) {
        error <- map["error"]
        requests <- map["requests"]
        version <- map["version"]
    }

}
