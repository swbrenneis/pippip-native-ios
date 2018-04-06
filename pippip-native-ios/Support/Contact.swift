//
//  Contact.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 3/31/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit

@objc class Contact: NSObject {

    @objc var contactId: Int
    @objc var publicId: String
    @objc var nickname: String?
    @objc var displayName: String {
        get {
            if nickname != nil {
                return nickname!
            }
            else {
                return publicId
            }
        }
    }
    @objc var status: String
    @objc var timestamp: Int64
    @objc var currentIndex: Int
    @objc var currentSequence: Int64
    @objc var authData: Data?
    @objc var nonce: Data?
    @objc var messageKeys: [ Data ]?

    @objc override init() {

        contactId = 0
        publicId = ""
        status = ""
        timestamp = 0
        currentIndex = 0
        currentSequence = 0

    }

    @objc init(_ contact: [AnyHashable: Any]) {

        let cid = contact[AnyHashable("contactId")] as? NSNumber
        contactId = cid?.intValue ?? 0
        publicId = contact[AnyHashable("publicId")] as? String ?? ""
        nickname = contact[AnyHashable("nickname")] as? String
        status = contact[AnyHashable("status")] as? String ?? ""
        let ts = contact[AnyHashable("timestamp")] as? NSNumber
        timestamp = ts?.int64Value ?? 0
        let ci = contact[AnyHashable("curentIndex")] as? NSNumber
        currentIndex = ci?.intValue ?? 0
        let cs = contact[AnyHashable("curentSequence")] as? NSNumber
        currentSequence = cs?.int64Value ?? 0
        authData = contact[AnyHashable("authData")] as? Data
        nonce = contact[AnyHashable("nonce")] as? Data
        messageKeys = contact[AnyHashable("messageKeys")] as? [ Data ]

    }

}
