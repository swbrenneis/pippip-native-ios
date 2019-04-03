//
//  DeleteContactRequest.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 6/2/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit
import ObjectMapper

class DeleteContactRequest: NSObject, EnclaveRequestProtocol {
    
    var method: String = "DeleteContact"
    var requestedId: String?
    var version: Double?

    init(requestedId: String) {
        self.requestedId = requestedId
        version = 1.0
    }

    required init?(map: Map) {
        
    }

    func mapping(map: Map) {
        method <- map["method"]
        requestedId <- map["requestedId"]
        version <- map["version"]
    }

}
