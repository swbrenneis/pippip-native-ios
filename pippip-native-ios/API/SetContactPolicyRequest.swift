//
//  SetContactPolicyRequest.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 6/2/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit
import ObjectMapper

class SetContactPolicyRequest: NSObject, EnclaveRequestProtocol {

    var method: String = "SetContactPolicy"
    var policy: String?
    var version: Float?
    
    init(policy: String) {
        self.policy = policy
    }

    required init?(map: Map) {
        
    }

    func mapping(map: Map) {
        method <- map["method"]
        policy <- map["policy"]
        version <- map["version"]
    }

}
