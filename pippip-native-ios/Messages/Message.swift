//
//  Message.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 4/12/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit

@objc class Message: NSObject {

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

    var config = Configurator()
    var contactManager = ContactManager()

    init(serverMessage: [AnyHashable: Any]) {

        let b64 = serverMessage["body"] as! String
        ciphertext = Data(base64Encoded: b64)
        let publicId = serverMessage["fromId"] as! String
        contactId = config.getContactId(publicId)
        let ki = serverMessage["keyIndex"] as! NSNumber
        keyIndex = ki.intValue
        messageType = serverMessage["messageType"] as! String
        originating = false
        let sq = serverMessage["sequence"] as! NSNumber
        sequence = sq.int64Value
        let ts = serverMessage["timestamp"] as! NSNumber
        timestamp = ts.int64Value

    }

    init(text: String, contact: Contact) {

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

    }

    func encodeForServer(publicId: String) -> [AnyHashable: Any] {

        var serverMessage = [AnyHashable: Any]()
        serverMessage["toId"] = publicId
        serverMessage["sequence"] = sequence
        serverMessage["keyIndex"] = keyIndex
        serverMessage["messageType"] = messageType
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

        return dbMessage

    }

}
