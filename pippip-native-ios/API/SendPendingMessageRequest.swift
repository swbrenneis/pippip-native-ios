//
//  SendPendingMessageRequest.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 3/20/19.
//  Copyright © 2019 seComm. All rights reserved.
//

import Foundation
import ObjectMapper

class SendPendingMessageRequest : Mappable, EnclaveRequestProtocol {

    var method = "SendPendingMessage"
    var recipient: String?
    var message: String?
    var version: Double?
    
    init(recipient: String, message: String) {
        self.recipient = recipient
        self.message = message
        version = 1.0
    }
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        recipient <- map["recipient"]
        message <- map["message"]
        version <- map["version"]
    }
    
    
}
