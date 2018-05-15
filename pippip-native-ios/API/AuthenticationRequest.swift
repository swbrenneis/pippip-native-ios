//
//  AuthenticationRequest.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 5/15/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit

class AuthenticationRequest: NSObject, PostPacketProtocol {

    var sessionState = SessionState()
    var restPath: String {
        if AccountManager.production() {
            return "/authenticator/authentication-request"
        }
        else {
            return "/authentication-request"
        }
    }

    var restTimeout: Double = 20.0

    var restPacket: [String : Any] {

        var packet = [String: Any]()
        packet["sessionId"] = sessionState.sessionId

        let rnd = CKSecureRandom()
        sessionState.clientAuthRandom = rnd.nextBytes(32)
        let codec = CKRSACodec()
        codec.put(sessionState.publicId)
        codec.putBlock(sessionState.accountRandom)
        codec.putBlock(sessionState.svpswSalt!)
        codec.putBlock(sessionState.clientAuthRandom!)
        packet["data"] = codec.encrypt(sessionState.serverPublicKey!).base64EncodedString()

        return packet

    }

}
