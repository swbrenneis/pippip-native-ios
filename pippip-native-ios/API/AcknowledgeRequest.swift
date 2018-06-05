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
    var id: String?
    var response: String?

    init(id: String, response: String) {
        self.id = id
        self.response = response
    }

    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        method <- map["method"]
        id <- map["id"]
        response <- map["response"]
    }

}
