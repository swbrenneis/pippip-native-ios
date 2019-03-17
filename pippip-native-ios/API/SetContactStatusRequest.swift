//
//  SetContactStatusRequest.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 3/4/19.
//  Copyright © 2019 seComm. All rights reserved.
//

import Foundation
import ObjectMapper

class SetContactStatusRequest : EnclaveRequestProtocol {

    var method = "SetContactStatus"
    var publicId: String?
    var status: String?
    var version: Float?
    
    init(publicId: String, status: String) {
        self.publicId = publicId
        self.status = status
    }

    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        publicId <- map["publicId"]
        status <- map["status"]
        version <- map["version"]
    }
    
    
}
