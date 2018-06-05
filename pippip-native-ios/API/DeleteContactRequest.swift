//
//  DeleteContactRequest.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 6/2/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit
import ObjectMapper

class DeleteContactRequest: NSObject, EnclaveRequestProtocol {
    
    var method: String = "DeleteContact"
    var publicId: String?

    init(publicId: String) {
        self.publicId = publicId
    }

    required init?(map: Map) {
        
    }

    func mapping(map: Map) {
        method <- map["method"]
        publicId <- map["publicId"]
    }

}
