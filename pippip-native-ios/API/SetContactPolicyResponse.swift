//
//  SetContactPolicyResponse.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 6/2/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit
import ObjectMapper

class SetContactPolicyResponse: NSObject, EnclaveResponseProtocol {

    var error: String?
    var policy: String?
    var result: String?

    required init?(map: Map) {
        if map.JSON["error"] == nil {
            if map.JSON["policy"] == nil {
                return nil
            }
            if map.JSON["result"] == nil {
                return nil
            }
        }
    }

    func mapping(map: Map) {
        error <- map["error"]
        policy <- map["policy"]
        result <- map["result"]
    }

}
