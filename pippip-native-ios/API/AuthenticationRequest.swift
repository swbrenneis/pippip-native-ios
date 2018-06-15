//
//  AuthenticationRequest.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 5/15/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit
import ObjectMapper

class AuthenticationRequest: NSObject, APIRequestProtocol {

    var path: String {
        if AccountSession.production {
            return "/authenticator/authentication-request"
        }
        else {
            return "/authentication-request"
        }
    }

    var timeout: Double = 10.0
    var data: String?
    var sessionId: Int32?
    var authToken: Int64?

    var sessionState = SessionState()

    override init() {

        sessionId = sessionState.sessionId
        let rnd = CKSecureRandom()
        sessionState.clientAuthRandom = rnd.nextBytes(32)
        let codec = CKRSACodec()
        codec.put(sessionState.publicId!)
        codec.putBlock(sessionState.accountRandom!)
        codec.putBlock(sessionState.svpswSalt!)
        codec.putBlock(sessionState.clientAuthRandom!)
        data = codec.encrypt(sessionState.serverPublicKey!).base64EncodedString()

        super.init()

    }

    required init?(map: Map) {
        
    }

    func mapping(map: Map) {
        sessionId <- map["sessionId"]
        data <- map["data"]
    }
    
}
