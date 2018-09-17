//
//  SyncContact.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 9/15/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit
import ObjectMapper

class SyncContact: NSObject, Mappable {

    var publicId: String?
    var status: String?
    var timestamp: Int64?
    var currentIndex: Int?
    var currentSequence: Int64?
    var action: String?

    init(contact: Contact, action: String) {

        publicId = contact.publicId
        status = contact.status
        timestamp = contact.timestamp
        currentIndex = contact.currentIndex
        currentSequence = contact.currentSequence
        self.action = action

    }

    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {

        publicId <- map["publicId"]
        status <- map["status"]
        timestamp <- map["timestamp"]
        currentIndex <- map["currentIndex"]
        currentSequence <- map["currentSequence"]
        action <- map["action"]

    }
    

}
