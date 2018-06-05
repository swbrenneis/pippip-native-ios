//
//  DeleteContactResponse.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 6/2/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit
import ObjectMapper

class DeleteContactResponse: NSObject, EnclaveResponseProtocol {

    var error: String?
    var publicId: String?
    var result: String?

    required init?(map: Map) {
        if map.JSON["error"] == nil {
            if map.JSON["publicId"] == nil {
                return nil
            }
            if map.JSON["result"] == nil {
                return nil
            }
        }
    }

    func mapping(map: Map) {
        error <- map["error"]
        publicId <- map["publicId"]
        result <- map["result"]
    }

}
