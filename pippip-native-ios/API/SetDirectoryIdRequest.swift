//
//  SetDirectoryIdRequest.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 6/2/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit
import ObjectMapper

class SetDirectoryIdRequest: NSObject, EnclaveRequestProtocol {

    var method: String = "SetDirectoryId"
    var oldDirectoryId: String?
    var newDirectoryId: String?
    var version: Float?
    
    init(oldDirectoryId: String, newDirectoryId: String) {
        self.oldDirectoryId = oldDirectoryId
        self.newDirectoryId = newDirectoryId
    }

    required init?(map: Map) {
        
    }

    func mapping(map: Map) {
        method <- map["method"]
        oldDirectoryId <- map["oldDirectoryId"]
        newDirectoryId <- map["newDirectoryId"]
        version <- map["version"]
    }

}
