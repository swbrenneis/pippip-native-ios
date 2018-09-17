//
//  SyncContactsRequest.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 9/15/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit
import ObjectMapper

class SyncContactsRequest: EnclaveRequestProtocol {

    var method: String = "SyncContacts"
    var contacts: [SyncContact]?
    
    init() {
        contacts = [SyncContact]()
    }
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {

        method <- map["method"]
        contacts <- map["contacts"]

    }

}
