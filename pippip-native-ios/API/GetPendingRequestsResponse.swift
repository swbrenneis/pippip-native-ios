//
//  GetPendingRequestsResponse.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 6/2/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit
import ObjectMapper

class GetPendingRequestsResponse: NSObject, EnclaveResponseProtocol {

    var error: String?
    var requests: [[String: String]]?

    required init?(map: Map) {
        if map.JSON["error"] == nil && map.JSON["requests"] == nil {
            return nil
        }
    }

    func mapping(map: Map) {
        error <- map["error"]
        requests <- map["requests"]
    }

}
