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
    var serverRequests: [ServerContactRequest]?
    var version: Double?

    required init?(map: Map) {
        if map.JSON["error"] == nil {
            guard let _ = map.JSON["serverRequests"] else { return nil }
            guard let _ = map.JSON["version"] else { return nil }
        }
    }

    required init?(jsonString: String) {
        
    }
    
    func mapping(map: Map) {
        error <- map["error"]
        serverRequests <- map["serverRequests"]
        version <- map["version"]
    }

}
