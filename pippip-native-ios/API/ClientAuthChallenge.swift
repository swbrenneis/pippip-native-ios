//
//  ClientAuthChallenge.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 5/15/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit

class ClientAuthChallenge: NSObject, PostPacketProtocol {

    var sessionState = SessionState()

    var restPath: String {
        if AccountManager.production() {
            return "/authenticator/authentication-challenge"
        }
        else {
            return "/authentication-challenge"
        }
    }

    var restTimeout: Double = 10.0

    var restPacket: [String : Any] {

        var packet = [String: Any]()
        packet["sessionId"] = sessionState.sessionId

        let hmac = getHMAC()
        packet["hmac"] = hmac.base64EncodedString()

        let sig = CKSignature(sha256: ())
        let signature = sig!.sign(sessionState.userPrivateKey!, withMessage: hmac)
        packet["signature"] = signature!.base64EncodedString()

        return packet

    }

    func getHMAC() -> Data {

        let hmac = CKHMAC(sha256: ())
        hmac!.setKey(s2k())
        var message = Data()
        message.append(sessionState.clientAuthRandom!)
        message.append("secomm server".data(using: .utf8)!)
        hmac!.setMessage(message)
        return hmac!.getHMAC()

    }

    func s2k() -> Data {

        let genpass = sessionState.genpass!
        let c = genpass.last!
        var count = Int32(c & 0x0f)
        if count == 0 {
            count = 0x0c
        }
        count = count << 16

        var message = Data()
        message.append(genpass)
        message.append("@secomm.org".data(using: .utf8)!)
        message.append(sessionState.accountRandom!)

        let digest = CKSHA256()
        var hash = digest!.digest(message)!
        count -= 32
        while count > 0 {
            var ctx = Data(message)
            ctx.append(hash)
            hash = digest!.digest(ctx)
            count -= Int32(32 + message.count)
        }
        return hash

    }

}
