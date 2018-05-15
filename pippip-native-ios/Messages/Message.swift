//
//  Message.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 4/12/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit

@objc class Message: NSObject, Comparable {

    static let currentVersion: Float = 2.0

    @objc var version: Float = 0
    @objc var acknowledged = false
    @objc var ciphertext: Data?
    @objc var contactId: Int = 0
    @objc var keyIndex: Int = 0
    @objc var messageId: Int64 = 0
    @objc var messageType = ""
    @objc var originating = true
    @objc var read = false
    @objc var sequence: Int64 = 0
    @objc var timestamp: Int64 = 0
    @objc var compressed = false

    var config = Configurator()
    var contactManager = ContactManager()

    init(serverMessage: [AnyHashable: Any]) {

        let b64 = serverMessage["body"] as! String
        ciphertext = Data(base64Encoded: b64)
        let publicId = serverMessage["fromId"] as! String
        contactId = contactManager.getContactId(publicId)
        let ki = serverMessage["keyIndex"] as! NSNumber
        keyIndex = ki.intValue
        messageType = serverMessage["messageType"] as! String
        originating = false
        let sq = serverMessage["sequence"] as! NSNumber
        sequence = sq.int64Value
        let ts = serverMessage["timestamp"] as! NSNumber
        timestamp = ts.int64Value
        if let comp = serverMessage["compressed"] as? NSNumber {
            compressed = comp.boolValue
        }
        else {
            compressed = false
        }
        version = Message.currentVersion

    }

    init(contact: Contact) {

        contactId = contact.contactId
        keyIndex = contact.currentIndex + 1
        if keyIndex > 9 {
            keyIndex = 0
        }
        contact.currentIndex = keyIndex
        sequence = contact.currentSequence + 1
        contact.currentSequence = sequence

        let contactManager = ContactManager()
        contactManager.updateContact(contact)

    }

    @objc init(dbMessage: DatabaseMessage) {

        acknowledged = dbMessage.acknowledged
        ciphertext = dbMessage.message
        contactId = dbMessage.contactId
        keyIndex = dbMessage.keyIndex
        messageId = Int64(dbMessage.messageId)
        messageType = dbMessage.messageType
        originating = dbMessage.sent
        read = dbMessage.read
        sequence = Int64(dbMessage.sequence)
        timestamp = Int64(dbMessage.timestamp)
        compressed = dbMessage.compressed
        version = dbMessage.version

    }

    func encodeForServer(publicId: String) -> [String: Any] {

        var serverMessage = [String: Any]()
        serverMessage["toId"] = publicId
        serverMessage["sequence"] = sequence
        serverMessage["keyIndex"] = keyIndex
        serverMessage["messageType"] = messageType
        serverMessage["compressed"] = compressed
        serverMessage["body"] = ciphertext?.base64EncodedString()
        return serverMessage

    }

    func encodeForDatabase() -> DatabaseMessage {

        let dbMessage = DatabaseMessage()
        dbMessage.messageType = messageType
        dbMessage.messageId = Int(messageId)
        dbMessage.contactId = contactId
        dbMessage.message = ciphertext
        dbMessage.acknowledged = acknowledged
        dbMessage.read = read
        dbMessage.sent = originating
        dbMessage.sequence = Int(sequence)
        dbMessage.keyIndex = keyIndex
        dbMessage.timestamp = Int(timestamp)
        dbMessage.compressed = compressed
        dbMessage.version = version

        return dbMessage

    }

    static func < (lhs: Message, rhs: Message) -> Bool {
        return lhs.timestamp < rhs.timestamp
    }
    
    static func == (lhs: Message, rhs: Message) -> Bool {
        return lhs.timestamp == rhs.timestamp
    }
    
}
