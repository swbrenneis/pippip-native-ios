//
//  APIObjects.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 5/28/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import Foundation
import ObjectMapper

class SessionResponse: Mappable {

    var serverPublicKey: String?
    var sessionId: Int32?
    var sessionTTL: Int64?
    var error: String?

    required init?(map: Map) {

    }

    func mapping(map: Map) {
        serverPublicKey <- map["serverPublicKey"]
        sessionId <- map["sessionId"]
        sessionTTL <- map["sessionTTL"]
        error <- map["error"]
    }

}
