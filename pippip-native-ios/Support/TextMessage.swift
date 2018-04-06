//
//  TextMessage.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 4/3/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit

class TextMessage: NSObject {

    @objc var messageId: Int64 = 0
    @objc var contactId: Int = 0
    @objc var ciphertext: Data?
    @objc var cleartext: String?
    @objc var publicId = ""
    @objc var nickname: String?
    @objc var messageType = "user"
    @objc var read = false
    @objc var acknowledged = false
    @objc var originating = true
    @objc var keyIndex: Int = 0
    @objc var sequence: Int64 = 0
    @objc var timestamp: Int64 = 0

    override init() {
        cleartext = ""
    }

    init(serverMessage: [AnyHashable: Any]) {

        publicId = serverMessage["toId"] as! String
        let sq = serverMessage["sequence"] as! NSNumber
        sequence = sq.int64Value
        let ki = serverMessage["keyIndex"] as! NSNumber
        keyIndex = ki.intValue
        messageType = serverMessage["messageType"] as! String
        let ts = serverMessage["timestamp"] as! NSNumber
        timestamp = ts.int64Value
        let b64 = serverMessage["body"] as! String
        ciphertext = Data(base64Encoded: b64)
        let config = ApplicationSingleton.instance().config!
        contactId = config.getContactId(publicId)
        originating = false
        
    }

    init(text: String, contact: Contact) {

        cleartext = text
        self.publicId = contact.publicId
        let config = ApplicationSingleton.instance().config!
        contactId = config.getContactId(publicId)
        nickname = contact.nickname
        keyIndex = contact.currentIndex + 1
        contact.currentIndex = keyIndex
        sequence = contact.currentSequence
        contact.currentSequence = sequence + 1
        timestamp = Int64(Date().timeIntervalSince1970 + 1000.0)

        let contactManager = ContactManager()
        contactManager.update(contact)

    }

    init(dbMessage: DatabaseMessage) {

        contactId = dbMessage.contactId
        messageId = Int64(dbMessage.messageId)
        messageType = dbMessage.messageType
        ciphertext = dbMessage.message
        cleartext = dbMessage.cleartext
        keyIndex = dbMessage.keyIndex
        sequence = Int64(dbMessage.sequence)
        timestamp = Int64(dbMessage.timestamp)
        read = dbMessage.read
        acknowledged = dbMessage.acknowledged
        originating = dbMessage.sent

    }

    func encodeForServer(_ contact: Contact) -> [AnyHashable: Any] {

        var encoded = [AnyHashable: Any]()
        encoded["toId"] = publicId
        encoded["keyIndex"] = keyIndex
        encoded["sequence"] = sequence
        encoded["messageType"] = messageType
        encrypt(contact)
        encoded["body"] = ciphertext?.base64EncodedString()

        return encoded

    }

    @objc func encrypt(_ contact: Contact) {

        let ivGen = CKIVGenerator()
        let iv = ivGen.generate(Int(sequence), withNonce: contact.nonce)
        let codec = CKGCMCodec()
        codec.setIV(iv)
        codec.put(cleartext)
        do {
            try ciphertext = codec.encrypt(contact.messageKeys![keyIndex], withAuthData: contact.authData)
        }
        catch {
            print("Error encrypting message - \(error)")
        }
        
    }

    func decrypt(_ contact: Contact) {

        let ivGen = CKIVGenerator()
        let iv = ivGen.generate(Int(sequence), withNonce: contact.nonce)
        let codec = CKGCMCodec()
        codec.setIV(iv)
        let error: NSErrorPointer = nil
        codec.decrypt(contact.messageKeys![keyIndex], withAuthData: contact.authData, withError: error)
        if let _ = error {
            let message = error?.debugDescription ?? "Unknown"
            print("Error decrypting message - \(message)")
        }
        else {
            cleartext = codec.getString()
        }

    }

}
