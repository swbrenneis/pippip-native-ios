//
//  SyncResponse.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 9/15/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit
import ObjectMapper

class SyncResponse: NSObject, Mappable {

    var publicId: String?
    var result: String?

    required init?(map: Map) {

        if map.JSON["publicId"] == nil || map.JSON["result"] == nil {
            return nil
        }

    }
    
    func mapping(map: Map) {

        publicId <- map["publicId"]
        result <- map["result"]

    }
    

}
