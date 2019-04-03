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
    
    static let ACCEPTED = "accepted"
    static let PENDING = "pending"
    static let IGNORED = "ignored"
    static let REJECTED = "rejected"
    
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

    static let currentVersion: Float = 2.4

    var version: Float = Contact.currentVersion
    var pendingMessage: String?
    var contactId: Int = 0
    var publicId: String = ""
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
                return publicId
            }
        }
    }
    var status: String = "invalid"
    var previousStatus: String = "invalid"
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
        version = Contact.currentVersion
        super.init()
    }

    init(contactId: Int) {

        self.contactId = contactId
        version = Contact.currentVersion
        
        super.init()

    }
    
    // Contact ID must be added after init!!
    init?(serverContact: ServerContact?) {

        guard let contact = serverContact else { return nil }
        version = Contact.currentVersion
        publicId = contact.publicId!
        status = contact.status!
        currentIndex = 0
        currentSequence = 1
        timestamp = Int64(contact.timestamp!)
        if status == "accepted" {
            authData = Data(base64Encoded: contact.authData!)
            nonce = Data(base64Encoded: contact.nonce!)
            messageKeys = [Data]()
            for key in contact.messageKeys! {
                messageKeys?.append(Data(base64Encoded: key)!)
            }
        }
        
        super.init()
        directoryId = contact.directoryId

    }

    static func ==(lhs: Contact, rhs: Contact) -> Bool {
        return lhs.contactId == rhs.contactId
    }

}
