//
//  GetRequestStatusRequest.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 6/2/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit
import ObjectMapper

class GetRequestStatusRequest: NSObject, EnclaveRequestProtocol {

    var method: String = "GetRequestStatus"
    var requestedIds: [String]?
    var version: Float?

    init(requestedIds: [String]) {
        self.requestedIds = requestedIds
    }

    required init?(map: Map) {
        
    }

    func mapping(map: Map) {
        method <- map["method"]
        requestedIds <- map["requestedIds"]
        version <- map["version"]
    }

}
