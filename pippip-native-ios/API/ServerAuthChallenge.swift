//
//  ServerAuthChallenge.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 5/29/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit
import ObjectMapper

class ServerAuthChallenge: APIResponseProtocol {

    var error: String?
    var sessionId: Int32?
    var authToken: Int64?
    var hmac: String?
    var signature: String?
    var postId: Int = 0

    var alertPresenter = AlertPresenter()
    var sessionState = SessionState()

    required init?(map: Map) {
        if map.JSON["sessionId"] == nil {
            return nil
        }
        if map.JSON["error"] == nil {
            if map.JSON["hmac"] == nil {
                return nil
            }
            if map.JSON["signature"] == nil {
                return nil
            }
        }
    }
    
    func mapping(map: Map) {

        sessionId <- map["sessionId"]
        error <- map["error"]
        hmac <- map["hmac"]
        signature <- map["signature"]

    }
    
    func processResponse() throws {

        if let responseError = error {
            throw APIResponseError.serverResponseError(error: responseError)
        }

        guard let sigData = Data(base64Encoded: signature!) else { throw APIResponseError.invalidServerResponse }
        guard let hmacData = Data(base64Encoded: hmac!) else { throw APIResponseError.invalidServerResponse }

        let sig = CKSignature(sha256: ())
        if !sig.verify(sessionState.serverPublicKey!, withMessage: hmacData, withSignature: sigData) {
            throw AuthenticationError.invalidSignature
        }

        if !validateHMAC(hmacData) {
            throw AuthenticationError.challengeFailed
        }

    }

    func validateHMAC(_ hmacData: Data) -> Bool {
        
        let hmacKey = s2k()
        let hmac256 = CKHMAC(sha256: ())
        hmac256.setKey(hmacKey)
        var message = Data()
        message.append(sessionState.serverAuthRandom!)
        message.append("secomm client".data(using: .utf8)!)
        hmac256.setMessage(message)
        return hmac256.authenticate(hmacData)

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
