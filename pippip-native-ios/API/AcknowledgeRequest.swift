//
//  AcknowledgeRequest.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 6/1/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit
import ObjectMapper

class AcknowledgeRequest: NSObject, EnclaveRequestProtocol {
    
    var method: String = "AcknowledgeRequest"
    var requestingId: String?
    var response: String?
    var version: Double?

    init(requestingId: String, response: String) {
        self.requestingId = requestingId
        self.response = response
        version = 1.1
    }

    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        method <- map["method"]
        requestingId <- map["requestingId"]
        response <- map["response"]
        version <- map["version"]
    }

}
