//
//  NewAccountResponse.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 5/30/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit
import ObjectMapper

class NewAccountResponse: NSObject, APIResponseProtocol {
    
    var error: String?
    var sessionId: Int32?
    var authToken: Int64?
    var data: String?
    var postId: Int = 0

    var alertPresenter = AlertPresenter()
    var sessionState = SessionState()
    
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

        if error != nil {
            alertPresenter.errorAlert(title: "New Account Error", message: error!)
            throw APIResponseError(errorString: error!)
        }

        if let encoded = Data(base64Encoded: data!) {
            let codec = CKRSACodec(data: encoded)
            try codec.decrypt(sessionState.userPrivateKey!)
            sessionState.accountRandom = codec.getBlock()
        }
        else {
            alertPresenter.errorAlert(title: "New Account Error", message: "Invalid response encoding")
            throw APIResponseError(errorString: "Response encoding error")
        }
        
    }

}
