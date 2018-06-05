//
//  GetMessagesRequest.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 6/2/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit
import ObjectMapper

class GetMessagesRequest: NSObject, EnclaveRequestProtocol {

    var method: String = "GetMessages"
    
    override init() {
        super.init()
    }

    required init?(map: Map) {
        
    }

    func mapping(map: Map) {
        method <- map["method"]
    }

}
