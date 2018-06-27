//
//  ServerContact.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 6/1/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit
import ObjectMapper

class ServerContact: NSObject, Mappable {
    
    var publicId: String?
    var directoryId: String?
    var status: String?
    var timestamp: Int?
    var authData: String?
    var nonce: String?
    var messageKeys: [String]?
    
    required init?(map: Map) {
        if map.JSON["publicId"] == nil {
            return nil
        }
        if map.JSON["status"] == nil {
            return nil
        }
        if map.JSON["timestamp"] == nil {
            return nil
        }
    }
    
    func mapping(map: Map) {

        publicId <- map["publicId"]
        directoryId <- map["directoryId"]
        status <- map["status"]
        timestamp <- map["timestamp"]
        authData <- map["authData"]
        nonce <- map["nonce"]
        messageKeys <- map["messageKeys"]

    }
    
}
