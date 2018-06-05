//
//  SetNicknameRequest.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 6/2/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit
import ObjectMapper

class SetNicknameRequest: NSObject, EnclaveRequestProtocol {

    var method: String = "SetNickname"
    var oldNickname: String?
    var newNickname: String?
    
    init(oldNickname: String, newNickname: String) {
        self.oldNickname = oldNickname
        self.newNickname = newNickname
    }

    required init?(map: Map) {
        
    }

    func mapping(map: Map) {
        method <- map["method"]
        oldNickname <- map["oldNickname"]
        newNickname <- map["newNickname"]
    }

}
