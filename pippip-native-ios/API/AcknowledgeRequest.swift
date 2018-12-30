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
    
    static let accept = "accept"
    static let ignore = "ignore"
    static let reject = "reject"
    
    var method: String = "AcknowledgeRequest"
    var requestingId: String?
    // Remove after server release
    var id: String?
    var response: String?
    var version: Float?

    init(requestingId: String, response: String) {
        self.requestingId = requestingId
        self.id = requestingId
        self.response = response
        version = 1.1
    }

    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        method <- map["method"]
        requestingId <- map["requestingId"]
        id <- map["id"]
        response <- map["response"]
        version <- map["version"]
    }

}
