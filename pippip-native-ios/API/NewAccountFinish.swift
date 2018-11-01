//
//  NewAccountFinish.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 5/30/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit
import ObjectMapper

class NewAccountFinish: NSObject, APIRequestProtocol {
    
    
    var path: String {
        if AccountSession.production {
            return "/authenticator/new-account-finish";
        }
        else {
            return "/new-account-finish";
        }
    }
    var timeout: Double = 20.0
    var sessionId: Int32?
    var authToken: Int64?       // Required by the protocol, not used
    var data: String?
    var deviceToken: String?
    var developer: Bool?

    var sessionState = SessionState()

    override init() {

        sessionId = sessionState.sessionId
        let codec = CKRSACodec()
        codec.putBlock(sessionState.genpass!)
        codec.putBlock(sessionState.enclaveKey!)
        codec.putBlock(sessionState.svpswSalt!)
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
