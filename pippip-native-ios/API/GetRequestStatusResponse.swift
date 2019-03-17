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

    var json: String?
    var error: String?
    var contacts: [ServerContact]?
    var version: Float?

    required init?(map: Map) {
        if map.JSON["error"] == nil {
            guard let _ = map.JSON["contacts"] else { return nil }
        }
    }

    required init?(jsonString: String) {
        
    }
    
    func mapping(map: Map) {
        error <- map["error"]
        contacts <- map["contacts"]
        version <- map["version"]
    }

}
