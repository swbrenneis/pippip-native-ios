//
//  UpdateWhitelistRequest.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 6/1/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit
import ObjectMapper

class UpdateWhitelistRequest: NSObject, EnclaveRequestProtocol {
    
    var method: String = "UpdateWhitelist"
    var id: String?
    var action: String?
    
    init(id: String, action: String) {
        self.id = id
        self.action = action
    }
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        method <- map["method"]
        id <- map["id"]
        action <- map["action"]
    }
    
}
