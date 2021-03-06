//
//  ServerAuthorized.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 5/29/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit
import ObjectMapper

class ServerAuthorized: NSObject, APIRequestProtocol {
    
    var path: String {
        if AccountSession.production {
            return "/authenticator/authorized";
        }
        else {
            return "/authorized";
        }
    }
    var timeout: Double = 10.0
    var sessionId: Int32?
    var authToken: Int64?
    var data: String?
    var deviceToken: String?
    var developer: Bool?
    
    var sessionState = SessionState()

    override init() {

        sessionId = sessionState.sessionId
        let codec = CKRSACodec()
        codec.putBlock(sessionState.enclaveKey!)
        let encoded = codec.encrypt(sessionState.serverPublicKey!)
        data = encoded.base64EncodedString()
        // Will be nil if simulator
        deviceToken = AccountSession.instance.deviceToken?.base64EncodedString()
        #if DEBUG
        developer = true
        #else
        developer = false
        #endif

        super.init()

    }

    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {

        sessionId <- map["sessionId"]
        data <- map["data"]
        deviceToken <- map["deviceToken"]
        developer <- map["developer"]

    }
    
}
