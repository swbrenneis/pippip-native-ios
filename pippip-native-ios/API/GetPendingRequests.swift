//
//  GetPendingRequests.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 6/2/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit
import ObjectMapper

class GetPendingRequests: NSObject, EnclaveRequestProtocol {

    var method: String = "GetPendingRequests"
    var version: Double?
    
    override init() {
        super.init()
        
        version = 1.0
    }
    
    required init?(map: Map) {
        
    }

    func mapping(map: Map) {
        method <- map["method"]
        version <- map["version"]
    }

}
