//
//  SetContactStatusResponse.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 3/4/19.
//  Copyright © 2019 seComm. All rights reserved.
//

import Foundation
import ObjectMapper

class SetContactStatusResponse : EnclaveResponseProtocol {
    
    var publicId: String?
    var status: String?
    var error: String?
    
    required init?(map: Map) {
        guard let _ = map.JSON["publicId"] else { return nil }
        guard let _ = map.JSON["status"] else { return nil }
    }
    
    func mapping(map: Map) {
        publicId <- map["publicId"]
        status <- map["status"]
    }
    
    
}
