//
//  NewAccountResponse.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 5/30/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit
import ObjectMapper
import CocoaLumberjack

class NewAccountResponse: NSObject, APIResponseProtocol {
    
    var error: String?
    var sessionId: Int32?
    var authToken: Int64?
    var data: String?
    var postId: Int = 0

    var alertPresenter = AlertPresenter()
    var sessionState = SessionState.instance
    
    required init?(map: Map) {
        if map.JSON["sessionId"] == nil {
            return nil
        }
        if map.JSON["error"] == nil &&  map.JSON["data"] == nil {
            return nil
        }
    }

    func mapping(map: Map) {

        sessionId <- map["sessionId"]
        error <- map["error"]
        data <- map["data"]
        
    }
    
    func processResponse() throws {

        if let encoded = Data(base64Encoded: data!) {
            do {
                let codec = CKRSACodec(data: encoded)
                try codec.decrypt(sessionState.userPrivateKey!)
                sessionState.accountRandom = codec.getBlock()
            }
            catch {
                DDLogError("Error decrypting new account response: \(error.localizedDescription)")
                throw ServerResponseError.invalidServerResponse
            }
        }
        else {
            throw ServerResponseError.invalidResponseEncoding
        }
        
    }

}
