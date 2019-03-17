//
//  EnclaveRequest.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 5/14/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import Foundation
import ObjectMapper

class EnclaveRequest: APIRequestProtocol {

    var path = "/enclave-request"
    var postType: PostType = .enclave
    var timeout: Double = 10.0
    var sessionId: Int32?
    var authToken: Int64?
    var request: String?

    var sessionState = SessionState()

    init() {

        sessionId = sessionState.sessionId
        authToken = sessionState.authToken

    }

    required init?(map: Map) {
        
    }

    func mapping(map: Map) {
        sessionId <- map["sessionId"]
        authToken <- map["authToken"]
        request <- map["request"]
    }
    
    func setRequest(_ enclaveRequest: EnclaveRequestProtocol) throws {

        if let json = enclaveRequest.toJSONString() {
            let codec = CKGCMCodec()
            codec.put(json)
            if let encoded = codec.encrypt(sessionState.enclaveKey!, withAuthData: sessionState.authData!) {
                request = encoded.base64EncodedString()
            }
            else {
                throw EnclaveError.cryptoError(error: codec.lastError!)
            }
        }
        else {
            throw EnclaveError.encodingError
        }

    }

}
