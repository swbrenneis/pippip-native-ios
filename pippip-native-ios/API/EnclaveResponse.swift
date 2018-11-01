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
    let sessionState = SessionState()

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
    
    func processResponse() -> String? {

        if let _ = error {
            return error
        }

        if sessionId != sessionState.sessionId || authToken != sessionState.authToken {
            print("Current session ID: \(sessionState.sessionId)")
            print("Current auth token: \(sessionState.authToken)")
            return "Invalid authentication! Please sign off immediately!"
        }

        if let responseData = Data(base64Encoded: response!) {
            do {
                let codec = CKGCMCodec(data: responseData)
                try codec.decrypt(sessionState.enclaveKey!, withAuthData: sessionState.authData!)
                json = codec.getString()
                return  nil
            }
            catch {
                DDLogError("Error decrypting enclave response: \(error.localizedDescription)")
                return "Invalid response from server"
            }
        }
        else {
            return "Server response encoding error"
        }

    }
    

}
