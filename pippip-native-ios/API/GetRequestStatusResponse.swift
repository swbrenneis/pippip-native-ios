//
//  GetRequestStatusResponse.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 6/2/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit
import ObjectMapper

class GetRequestStatusResponse: NSObject, EnclaveResponseProtocol {

    var error: String?
    var contacts: [ServerContact]?

    required init?(map: Map) {
        if map.JSON["error"] == nil && map.JSON["contacts"] == nil {
            return nil
        }
    }

    func mapping(map: Map) {
        error <- map["error"]
        contacts <- map["contacts"]
    }

}
