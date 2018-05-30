//
//  Logout.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 5/15/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit

class Logout: NSObject, APIRequestProtocol {

    var path: String  {
        if AccountManager.production() {
            return "/authenticator/logout"
        }
        else {
            return "/logout"
        }
    }
    var timeout: Double = 10.0
    var sessionId: Int32?
    var authToken: Int64?

    var sessionState = SessionState()

    override init() {
        sessionId = sessionState.sessionId
        authToken = sessionState.authToken
        super.init()
    }

    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {

        sessionId <- map["sessionId"]
        authToken <- map["authToken"]

    }

}
