//
//  ServerMessage.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 6/2/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit
import ObjectMapper

class ServerMessage: NSObject, Mappable {

    var fromId: String?
    var toId: String?
    var sequence: Int?
    var keyIndex: Int?
    var timestamp: Int?
    var messageType: String?
    var compressed: Bool?
    var body: String?

    override init() {
        super.init()
    }

    required init?(map: Map) {
        if map.JSON["fromId"] == nil || map.JSON["toId"] == nil || map.JSON["sequence"] == nil
            || map.JSON["keyIndex"] == nil || map.JSON["messageType"] == nil
            || map.JSON["compressed"] == nil || map.JSON["body"] == nil {
            return nil
        }
    }

    func mapping(map: Map) {
        fromId <- map["fromId"]
        toId <- map["toId"]
        sequence <- map["sequence"]
        keyIndex <- map["keyIndex"]
        timestamp <- map["timestamp"]
        messageType <- map["messageType"]
        compressed <- map["compressed"]
        body <- map["body"]
    }

}
