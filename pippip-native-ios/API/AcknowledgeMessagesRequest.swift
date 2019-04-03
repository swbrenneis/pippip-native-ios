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
        guard let _ = map.JSON["publicId"] else { return nil }
        guard let _ = map.JSON["sequence"] else { return nil }
        guard let _ = map.JSON["timestamp"] else { return nil }
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
        version = 1.0
    }

    required init?(map: Map) {
        
    }

    func mapping(map: Map) {
        method <- map["method"]
        messages <- map["messages"]
        version <- map["version"]
    }

}
