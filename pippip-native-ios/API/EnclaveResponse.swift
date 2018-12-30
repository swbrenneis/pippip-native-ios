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

class EnclaveResponse: NSObject, APIResponseProtocol {

    var sessionId: Int32?
    var authToken: Int64?
    var error: String?
    var response: String?
    var needsAuth: Bool?
    var postId: Int = 0
    var json: String = ""

    let alertPresenter = AlertPresenter()
    let sessionState = SessionState.instance

    required init?(map: Map) {
        if map.JSON["sessionId"] == nil {
            return nil
        }
        if map.JSON["authToken"] == nil {
            return nil
        }
        if map.JSON["error"] == nil {
            if map.JSON["response"] == nil {
                return nil
            }
            if map.JSON["needsAuth"] == nil {
                return nil
            }
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

        if sessionId != sessionState.sessionId || authToken != sessionState.authToken {
            DDLogInfo("Current session ID: \(sessionState.sessionId)")
            DDLogInfo("Current auth token: \(sessionState.authToken)")
            throw ServerResponseError.invalidAuthentication
        }

        if let responseData = Data(base64Encoded: response!) {
            do {
                let codec = CKGCMCodec(data: responseData)
                try codec.decrypt(sessionState.enclaveKey!, withAuthData: sessionState.authData!)
                json = codec.getString()
            }
            catch {
                DDLogError("Error decrypting enclave response: \(error.localizedDescription)")
                throw ServerResponseError.invalidServerResponse
            }
        }
        else {
            throw ServerResponseError.invalidServerResponse
        }

    }
    

}
