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

    var method: String = "AddContactRequest"
    var publicId: String?
    var directoryId: String?
    var initialMessage: String?
    var version: Float?

    init(publicId: String?, directoryId: String?, initialMessage: String?) {
        self.publicId = publicId
        self.directoryId = directoryId
        self.initialMessage = initialMessage
        version = 1.2
    }

    required init?(map: Map) {
        
    }

    func mapping(map: Map) {
        method <- map["method"]
        publicId <- map["publicId"]
        directoryId <- map["directoryId"]
        initialMessage <- map["initialMessage"]
    }

}
