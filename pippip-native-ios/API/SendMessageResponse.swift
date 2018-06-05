//
//  SendMessageResponse.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 6/2/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit
import ObjectMapper

class SendMessageResponse: NSObject, EnclaveResponseProtocol {

    var error: String?
    var result: String?
    var publicId: String?
    var sequence: Int?
    var timestamp: Int?

    required init?(map: Map) {
        if map.JSON["error"] == nil {
            if map.JSON["result"] == nil || map.JSON["publicId"] == nil || map.JSON["sequence"] == nil
                || map.JSON["timestamp"] == nil {
                return nil
            }
        }
    }

    func mapping(map: Map) {
        error <- map["error"]
        result <- map["result"]
        publicId <- map["publicId"]
        sequence <- map["sequence"]
        timestamp <- map["timestamp"]
    }

}
