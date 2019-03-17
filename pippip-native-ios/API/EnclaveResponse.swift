//
//  EnclaveResponse.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 5/30/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit
import ObjectMapper
import CocoaLumberjack

class EnclaveResponse: APIResponseProtocol {

    var sessionId: Int32?
    var authToken: Int64?
    var error: String?
    var response: String?
    var needsAuth: Bool?
    var json: String = ""

    let alertPresenter = AlertPresenter()
    let sessionState = SessionState()

    required init?(map: Map) {
        guard let _ = map.JSON["needsAuth"] else { return nil }
        guard let _ =  map.JSON["sessionId"] else { return nil }
        guard let _ = map.JSON["authToken"] else { return nil }
        if map.JSON["error"] == nil {
            guard let _ = map.JSON["response"] else { return nil }
        }
    }
    
    func mapping(map: Map) {

        sessionId <- map["sessionId"]
        authToken <- map["authToken"]
        error <- map["error"]
        response <- map["response"]
        needsAuth <- map["needsAuth"]

    }
    
    func processResponse() throws {

        if let errorResponse = error {
            throw APIResponseError.serverResponseError(error: errorResponse)
        }
        
        if sessionId != sessionState.sessionId || authToken != sessionState.authToken {
            DDLogInfo("Current session ID: \(sessionState.sessionId)")
            DDLogInfo("Current auth token: \(sessionState.authToken)")
            throw APIResponseError.invalidAuth
        }

        if let responseData = Data(base64Encoded: response!) {
            let codec = CKGCMCodec(data: responseData)
            try codec.decrypt(sessionState.enclaveKey!, withAuthData: sessionState.authData!)
            json = codec.getString()
        }
        else {
            throw APIResponseError.invalidServerResponse
        }

    }
    

}
