//
//  MatchNicknameRequest.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 6/2/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit
import ObjectMapper

class MatchNicknameRequest: NSObject, EnclaveRequestProtocol {

    var method: String = "MatchNickname"
    var publicId: String?
    var nickname: String?
    
    init(publicId: String?, nickname: String?) {
        self.publicId = publicId
        self.nickname = nickname
    }

    required init?(map: Map) {
        
    }

    func mapping(map: Map) {
        method <- map["method"]
        publicId <- map["publicId"]
        nickname <- map["nickname"]
    }

}
