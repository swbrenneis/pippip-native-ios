//
//  ServerContact.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 6/1/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit
import ObjectMapper

class ServerContact: Mappable {
    
    var publicId: String?
    var directoryId: String?
    var status: String?
    var timestamp: Int?
    var version: Float?
    var authData: String?
    var nonce: String?
    var messageKeys: [String]?
    
    required init?(map: Map) {
        guard let _ = map.JSON["publicId"] as? String else { return nil }
        guard let _ = map.JSON["status"] as? String else { return nil }
        guard let _ = map.JSON["timestamp"] as? Int else { return nil }
        guard let _ = map.JSON["version"] as? Float else { return nil }
    }
    
    func mapping(map: Map) {

        publicId <- map["publicId"]
        directoryId <- map["directoryId"]
        status <- map["status"]
        timestamp <- map["timestamp"]
        version <- map["version"]
        authData <- map["authData"]
        nonce <- map["nonce"]
        messageKeys <- map["messageKeys"]

    }
    
}
