//
//  AcknowledgeMessagesRequest.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 6/2/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit
import ObjectMapper

class Triplet: Mappable {

    var publicId: String?
    var sequence: Int?
    var timestamp: Int?

    init(publicId: String, sequence: Int, timestamp: Int) {
        self.publicId = publicId
        self.sequence = sequence
        self.timestamp = timestamp
    }
    
    required init?(map: Map) {
        if map.JSON["publicId"] == nil {
            return nil
        }
        if map.JSON["sequence"] == nil {
            return nil
        }
        if map.JSON["timestamp"] == nil {
            return nil
        }
    }

    func mapping(map: Map) {
        publicId <- map["publicId"]
        sequence <- map["sequence"]
        timestamp <- map["timestamp"]
    }

}

class AcknowledgeMessagesRequest: NSObject, EnclaveRequestProtocol {

    var method: String = "AcknowledgeMessages"
    var messages: [Triplet]?
    var version: Double?

    init(messages: [Triplet]) {
        self.messages = messages
    }

    required init?(map: Map) {
        
    }

    func mapping(map: Map) {
        method <- map["method"]
        messages <- map["messages"]
        version <- map["version"]
    }

}
