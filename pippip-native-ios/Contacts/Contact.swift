//
//  Contact.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 3/31/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit

struct Entity {

    var publicId: String
    var nickname: String?

}

@objc class Contact: NSObject {

    static let currentVersion: Float = 1.0

    @objc var version: Float
    @objc var contactId: Int
    @objc var publicId: String
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
    @objc var status: String
    @objc var timestamp: Int64
    @objc var currentIndex: Int
    @objc var currentSequence: Int64
    @objc var authData: Data?
    @objc var nonce: Data?
    @objc var messageKeys: [ Data ]?
    @objc override var hashValue: Int {
        return contactId
    }

    @objc override init() {

        version = Contact.currentVersion
        contactId = 0
        publicId = ""
        status = ""
        timestamp = 0
        currentIndex = 0
        currentSequence = 1

        super.init()

    }
    
    @objc init(contactId: Int) {

        version = Contact.currentVersion
        self.contactId = contactId
        publicId = ""
        status = ""
        timestamp = 0
        currentIndex = 0
        currentSequence = 1
        
        super.init()

    }
    
    @objc init?(serverContact: ServerContact) {

        version = Contact.currentVersion
        publicId = serverContact.publicId!
        let contactManager = ContactManager()
        contactId = contactManager.getContactId(publicId)
        status = serverContact.status!
        currentIndex = 0
        currentSequence = 1
        timestamp = Int64(serverContact.timestamp!)
        authData = Data(base64Encoded: serverContact.authData!)
        nonce = Data(base64Encoded: serverContact.nonce!)
        messageKeys = [Data]()
        for key in serverContact.messageKeys! {
            messageKeys?.append(Data(base64Encoded: key)!)
        }
        
        super.init()

    }

    static func ==(lhs: Contact, rhs: Contact) -> Bool {
        return lhs.contactId == rhs.contactId
    }

}
