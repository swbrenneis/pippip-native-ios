//
//  EnclaveRequest.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 5/14/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import Foundation

class EnclaveRequest: NSObject, PostPacketProtocol {

    var sessionState = SessionState()
    private var packet = [String: Any]()

    var restPath: String {
        if AccountManager.production() {
            return "/enclave/enclave-request"
        }
        else {
            return "/enclave-request"
        }
    }
    var restTimeout: Double = 10.0

    var restPacket: [String : Any] {
        packet["sessionId"] = sessionState.sessionId
        packet["authToken"] = sessionState.authToken
        return packet
    }

    func setRequest(_ request: [String: Any]) throws {

        let jsonData = try JSONSerialization.data(withJSONObject: request, options: [])
        let json = String(data: jsonData, encoding: .utf8)

        let codec = CKGCMCodec()
        codec.put(json)
        let encoded = try codec.encrypt(sessionState.enclaveKey, withAuthData: sessionState.authData)
        packet["request"] = encoded.base64EncodedString()

    }

}
