//
//  SetDirectoryIdResponse.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 6/2/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit
import ObjectMapper

enum DirectoryIdResult: String {
    case added = "added"
    case deleted = "deleted"
    case in_use = "in_use"
    case updated = "updated"
}

class SetDirectoryIdResponse: NSObject, EnclaveResponseProtocol {

    static let added = "added"
    static let deleted = "deleted"
    static let in_use = "in_use"
    static let updated = "updated"
    
    var error: String?
    var result: String?

    required init?(map: Map) {
        if map.JSON["error"] == nil && map.JSON["result"] == nil {
            return nil
        }
    }

    func mapping(map: Map) {
        error <- map["error"]
        result <- map["result"]
    }

}
