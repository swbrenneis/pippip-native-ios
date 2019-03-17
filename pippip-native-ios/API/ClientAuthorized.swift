//
//  ClientAuthorized.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 5/29/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit
import ObjectMapper

class ClientAuthorized: NSObject, APIResponseProtocol {

    var error: String?
    var sessionId: Int32?
    var authToken: Int64?

    var alertPresenter = AlertPresenter()
    var sessionState = SessionState()

    required init?(map: Map) {
        if map.JSON["sessionId"] == nil {
            return nil
        }
        if map.JSON["authToken"] == nil {
            return nil
        }
    }
    
    func mapping(map: Map) {

        sessionId <- map["sessionId"]
        error <- map["error"]
        authToken <- map["authToken"]

    }
    
    func processResponse() throws {

        if let responseError = error {
            throw APIResponseError.serverResponseError(error: responseError)
        }

        sessionState.authToken = authToken!

    }
    

}
