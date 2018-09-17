//
//  Contact.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 3/31/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit

class Contact: NSObject {

    static let currentVersion: Float = 2.0

    var version: Float = Contact.currentVersion
    var contactId: Int = 0
    var publicId: String = ""
    var directoryId: String?
    var displayName: String {
        get {
            if let did = directoryId {
                return did
            }
            else {
                let shortened = publicId.prefix(10) + "..."
                return "\(shortened)"
            }
        }
    }
    var status: String = "invalid"
    var timestamp: Int64 = 0
    var currentIndex: Int = 0
    var currentSequence: Int64 = 1
    var authData: Data?
    var nonce: Data?
    var messageKeys: [ Data ]?
    override var hashValue: Int {
        return contactId
    }

    override init() {
        super.init()
    }

    init(contactId: Int) {

        self.contactId = contactId
        
        super.init()

    }
    
    // Contact ID must be added after init!!
    init(serverContact: ServerContact) {

        version = Contact.currentVersion
        publicId = serverContact.publicId!
        status = serverContact.status!
        currentIndex = 0
        currentSequence = 1
        timestamp = Int64(serverContact.timestamp!)
        if status == "accepted" {
            authData = Data(base64Encoded: serverContact.authData!)
            nonce = Data(base64Encoded: serverContact.nonce!)
            messageKeys = [Data]()
            for key in serverContact.messageKeys! {
                messageKeys?.append(Data(base64Encoded: key)!)
            }
        }
        
        super.init()

    }

    static func ==(lhs: Contact, rhs: Contact) -> Bool {
        return lhs.contactId == rhs.contactId
    }

}
