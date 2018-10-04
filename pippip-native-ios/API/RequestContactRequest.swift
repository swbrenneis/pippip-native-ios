//
//  RequestContactRequest.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 6/2/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit
import ObjectMapper

class RequestContactRequest: NSObject, EnclaveRequestProtocol {

    var method: String = "RequestContact"
    var requestedId: String?
    // Remove when new server build is pushed
    var id: String?
    var retry: Bool?
    var version: Float?

    init(requestedId: String, retry: Bool) {
        self.requestedId = requestedId
        self.id = requestedId
        self.retry = retry
        version = 1.1
    }

    required init?(map: Map) {
        
    }

    func mapping(map: Map) {
        method <- map["method"]
        requestedId <- map["requestedId"]
        id <- map["id"]
        retry <- map["retry"]
    }

}
