//
//  MatchDirectoryIdRequest.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 6/2/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit
import ObjectMapper

class MatchDirectoryIdRequest: NSObject, EnclaveRequestProtocol {

    var method: String = "MatchDirectoryId"
    var publicId: String?
    var directoryId: String?
    var version: Double?
    
    init(publicId: String?, directoryId: String?) {
        self.publicId = publicId
        self.directoryId = directoryId
    }

    required init?(map: Map) {
        
    }

    func mapping(map: Map) {
        method <- map["method"]
        publicId <- map["publicId"]
        directoryId <- map["directoryId"]
        version <- map["version"]
    }

}
