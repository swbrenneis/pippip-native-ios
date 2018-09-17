//
//  Message.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 4/12/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit

class Message: NSObject, Comparable {

    static let currentVersion: Float = 2.0

    var version: Float = Message.currentVersion
    var acknowledged = false
    var ciphertext: Data?
    var contactId: Int = 0
    var keyIndex: Int = 0
    var messageId: Int64 = 0
    var messageType = ""
    var originating = true
    var read = false
    var sequence: Int64 = 0
    var timestamp: Int64 = 0
    var compressed = false
    var failed = false

    var config = Configurator()
    var contactManager = ContactManager()

    init(serverMessage: ServerMessage) {

        ciphertext = Data(base64Encoded: serverMessage.body!)
        contactId = contactManager.getContactId(serverMessage.fromId!)
        keyIndex = serverMessage.keyIndex!
        messageType = serverMessage.messageType!
        originating = false
        sequence = Int64(serverMessage.sequence!)
        timestamp = Int64(serverMessage.timestamp!)
        compressed = serverMessage.compressed!

    }

    init?(contact: Contact) {

        contactId = contact.contactId
        keyIndex = contact.currentIndex + 1
        if keyIndex > 9 {
            keyIndex = 0
        }
        contact.currentIndex = keyIndex
        sequence = contact.currentSequence + 1
        contact.currentSequence = sequence

        let contactManager = ContactManager()
        do {
            try contactManager.updateContact(contact)
        }
        catch {
            print("Error updating contact: \(error)")
            return nil
        }

    }

    init(dbMessage: DatabaseMessage) {

        acknowledged = dbMessage.acknowledged
        ciphertext = dbMessage.ciphertext
        contactId = dbMessage.contactId
        keyIndex = dbMessage.keyIndex
        messageId = Int64(dbMessage.messageId)
        messageType = dbMessage.messageType
        originating = dbMessage.originating
        read = dbMessage.read
        sequence = Int64(dbMessage.sequence)
        timestamp = Int64(dbMessage.timestamp)
        compressed = dbMessage.compressed
        failed = dbMessage.failed
        version = dbMessage.version

    }

    func decrypt(notify: Bool) {

        assert(false, "Must be overridden in subclasses")

    }

    func encodeForServer(publicId: String) -> ServerMessage {

        let serverMessage = ServerMessage()
        serverMessage.toId = publicId
        serverMessage.sequence = Int(sequence)
        serverMessage.keyIndex = keyIndex
        serverMessage.messageType = messageType
        serverMessage.compressed = compressed
        serverMessage.body = ciphertext?.base64EncodedString()
        return serverMessage

    }

    func encodeForDatabase() -> DatabaseMessage {

        let dbMessage = DatabaseMessage()
        dbMessage.messageType = messageType
        dbMessage.messageId = messageId
        dbMessage.contactId = contactId
        dbMessage.ciphertext = ciphertext
        dbMessage.acknowledged = acknowledged
        dbMessage.read = read
        dbMessage.originating = originating
        dbMessage.sequence = sequence
        dbMessage.keyIndex = keyIndex
        dbMessage.timestamp = timestamp
        dbMessage.compressed = compressed
        dbMessage.failed = failed
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
