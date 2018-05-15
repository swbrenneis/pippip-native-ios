//
//  Logout.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 5/15/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit

class Logout: NSObject, PostPacketProtocol {

    var sessionState = SessionState()
    var restPath: String {
        if AccountManager.production() {
            return "/authenticator/logout"
        }
        else {
            return "/logout"
        }
    }
    var restTimeout: Double = 10.0

    var restPacket: [String : Any] {
        var packet = [String: Any]()
        packet["sessionId"] = sessionState.sessionId
        packet["authToken"] = sessionState.authToken
        return packet

    }

}
