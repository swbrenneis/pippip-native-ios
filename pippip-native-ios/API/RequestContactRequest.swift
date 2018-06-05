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
    var id: String?
    var retry: Bool?

    init(id: String, retry: Bool) {
        self.id = id
        self.retry = retry
    }

    required init?(map: Map) {
        
    }

    func mapping(map: Map) {
        method <- map["method"]
        id <- map["id"]
        retry <- map["retry"]
    }

}
