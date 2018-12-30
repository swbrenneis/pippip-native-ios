//
//  NewAccountRequest.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 5/30/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit
import ObjectMapper

class NewAccountRequest: NSObject, APIRequestProtocol {
    
    var path: String {
        if AccountSession.production {
            return "/authenticator/new-account-request"
        }
        else {
            return "/new-account-request"
        }
    }
    var timeout: Double = 10.0
    var sessionId: Int32?
    var authToken: Int64?
    var publicId: String?
    var userPublicKey: String?
    
    var sessionState = SessionState.instance

    override init() {

        sessionId = sessionState.sessionId
        publicId = sessionState.publicId
        userPublicKey = sessionState.userPublicKeyPEM

    }

    required init?(map: Map) {
        
    }

    func mapping(map: Map) {
        sessionId <- map["sessionId"]
        publicId <- map["publicId"]
        userPublicKey <- map["userPublicKey"]
    }
    
}
