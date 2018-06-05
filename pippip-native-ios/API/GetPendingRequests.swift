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
    
    override init() {
        super.init()
    }
    
    required init?(map: Map) {
        
    }

    func mapping(map: Map) {
        method <- map["method"]
    }

}
