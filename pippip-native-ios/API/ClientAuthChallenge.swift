//
//  ClientAuthChallenge.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 5/15/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit
import ObjectMapper

class ClientAuthChallenge: NSObject, APIRequestProtocol {

    var path: String {
        if AccountManager.production() {
            return "/authenticator/authentication-challenge"
        }
        else {
            return "/authentication-challenge"
        }
    }
    var timeout: Double = 10.0
    var sessionId: Int32?
    var authToken: Int64?
    var hmac: String?
    var signature: String?
    
    var sessionState = SessionState()

    override init() {
        super.init()

        sessionId = sessionState.sessionId
        let hmacData = getHMAC()
        hmac = hmacData.base64EncodedString()
        let sig = CKSignature(sha256: ())
        let sigData = sig.sign(sessionState.userPrivateKey!, withMessage: hmacData)
        signature = sigData.base64EncodedString()

    }

    required init?(map: Map) {
        
    }

    func mapping(map: Map) {

        sessionId <- map["sessionId"]
        hmac <- map["hmac"]
        signature <- map["signature"]

    }

    func getHMAC() -> Data {

        let hmac256 = CKHMAC(sha256: ())
        hmac256.setKey(s2k())
        var message = Data()
        message.append(sessionState.clientAuthRandom!)
        message.append("secomm server".data(using: .utf8)!)
        hmac256.setMessage(message)
        return hmac256.getHMAC()

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
        var hash = digest.digest(message)
        count -= 32
        while count > 0 {
            var ctx = Data(message)
            ctx.append(hash)
            hash = digest.digest(ctx)
            count -= Int32(32 + message.count)
        }
        return hash

    }

}
