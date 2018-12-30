//
//  Contact.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 3/31/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit
import CocoaLumberjack

class Contact: NSObject, Comparable {
    
    static let currentVersion: Float = 2.0

    var version: Float = Contact.currentVersion
    var contactId: Int = -1
    var publicId: String?
    private var realDirectoryId: String?
    var directoryId: String? {
        get {
            return realDirectoryId
        }
        set {
            if let did = newValue {
                if did.utf8.count == 0 {
                    realDirectoryId =  nil
                }
                else {
                    realDirectoryId = did
                }
            }
            else {
                realDirectoryId = newValue
            }
        }
    }
    var displayName: String {
        get {
            if let did = realDirectoryId {
                return did
            }
            else {
                return publicId!
            }
        }
    }
    var status: String = "invalid"
    var initialMessage: String?
    var timestamp: Int64 = 0
    var currentIndex: Int = 0
    var currentSequence: Int64 = 1
    var authData: Data?
    var nonce: Data?
    var messageKeys: [ Data ]?
    override var hash: Int {
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
        publicId = serverContact.publicId
        realDirectoryId = serverContact.directoryId
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

    static func < (lhs: Contact, rhs: Contact) -> Bool {
        
        switch lhs.status {
        case "pending":
            switch rhs.status {
            case "pending":
                return lhs.displayName.uppercased().utf8.first! < rhs.displayName.uppercased().utf8.first!
            case "accepted":
                return true
            case "rejected":
                return true
            case "ignored":
                return true
            default:
                DDLogError("Invalid contact status in comparator")
            }
        case "accepted":
            switch rhs.status {
            case "pending":
                return false
            case "accepted":
                return lhs.displayName.uppercased().utf8.first! < rhs.displayName.uppercased().utf8.first!
            case "rejected":
                return true
            case "ignored":
                return true
            default:
                DDLogError("Invalid contact status in comparator")
            }
        case "rejected":
            switch rhs.status {
            case "pending":
                return false
            case "accepted":
                return false
            case "rejected":
                return lhs.displayName.uppercased().utf8.first! < rhs.displayName.uppercased().utf8.first!
            case "ignored":
                return true
            default:
                DDLogError("Invalid contact status in comparator")
            }
        case "ignored":
            switch rhs.status {
            case "pending":
                return false
            case "accepted":
                return false
            case "rejected":
                return false
            case "ignored":
                return lhs.displayName.uppercased().utf8.first! < rhs.displayName.uppercased().utf8.first!
            default:
                DDLogError("Invalid contact status in comparator")
            }
        default:
            DDLogError("Invalid contact status in comparator")
        }
        
        return true
        
    }
    
}
