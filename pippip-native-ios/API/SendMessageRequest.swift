//
//  SendMessageRequest.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 6/2/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit
import ObjectMapper

class SendMessageRequest: NSObject, EnclaveRequestProtocol {

    var method: String = "SendMessage"
    var message: ServerMessage?
    
    init(message: ServerMessage) {
        self.message = message
    }

    required init?(map: Map) {
        
    }

    func mapping(map: Map) {
        method <- map["method"]
        message <- map["message"]
    }

}
