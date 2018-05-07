//
//  Contact.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 3/31/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit

@objc class Contact: NSObject {

    @objc var contactId: Int32 = 0
    @objc var publicId = ""
    @objc var nickname: String?
    @objc var displayName: String {
        get {
            if nickname != nil {
                return nickname!
            }
            else {
                let shortened = publicId.prefix(10) + "..."
                return String(shortened)
            }
        }
    }
    @objc var status = ""
    @objc var timestamp: Int64 = 0
    @objc var currentIndex: Int32 = 0
    @objc var currentSequence: Int64 = 1
    @objc var authData: Data?
    @objc var nonce: Data?
    @objc var messageKeys: [ Data ]?

    override init() {
        super.init()
    }

    @objc init(contactId: Int32) {

        self.contactId = contactId
        
        super.init()

    }
    
    @objc init?(serverContact: [AnyHashable: Any]) {

        guard let puid = serverContact["publicId"] as? String else { return nil }
        publicId = puid
        let contactManager = ContactManager()
        guard let cid = contactManager.getContactId(publicId) else { return nil }
        contactId = cid
        guard let stat = serverContact["status"] as? String else { return nil }
        status = stat
        currentIndex = 0
        currentSequence = 1
        guard let ts = serverContact["timestamp"] as? NSNumber else { return nil }
        timestamp = ts.int64Value
        guard let ad = serverContact["authData"] as? String else { return nil }
        authData = Data(base64Encoded: ad)
        guard let n = serverContact["nonce"] as? String else { return nil }
        nonce = Data(base64Encoded: n)
        guard let keys = serverContact["messageKeys"] as? [String] else { return nil }
        messageKeys = [Data]()
        for key in keys {
            messageKeys?.append(Data(base64Encoded: key)!)
        }
        
        super.init()

    }

}
