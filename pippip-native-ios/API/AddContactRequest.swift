//
//  RequestContactRequest.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 6/2/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit
import ObjectMapper

class AddContactRequest: NSObject, EnclaveRequestProtocol {

    var method: String = "RequestContact"
    var publicId: String?
    var directoryId: String?
    var initialMessage: String?
    var retry: Bool?
    var version: Float?

    init(contact: Contact, retry: Bool) {
        self.publicId = contact.publicId
        self.directoryId = contact.directoryId
        self.initialMessage = contact.initialMessage
        self.retry = retry
        version = 1.2
    }

    required init?(map: Map) {
        
    }

    func mapping(map: Map) {
        method <- map["method"]
        publicId <- map["publicId"]
        directoryId <- map["directoryId"]
        initialMessage <- map["initialMessage"]
        retry <- map["retry"]
    }

}
