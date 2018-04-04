//
//  TextMessage.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 4/3/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit

class TextMessage {

    var messageId: Int64 = 0
    var contactId: Int = 0
    var ciphertext: Data?
    var cleartext: String?
    var publicId = ""
    var nickname: String?
    var messageType = "user"
    var read = false
    var acknowledged = false
    var originating = true
    var keyIndex: Int = 0
    var sequence: Int64 = 0
    var timestamp: Int64 = 0

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
        messageId = Int64(config.newMessageId())
        originating = false
        
    }

    init(text: String, publicId: String) {

        cleartext = text
        self.publicId = publicId
        let config = ApplicationSingleton.instance().config!
        messageId = Int64(config.newMessageId())
        contactId = config.getContactId(publicId)
        let contactManager = ContactManager()
        let contact = contactManager.getContact(publicId)!
        nickname = contact.nickname
        keyIndex = contact.currentIndex + 1
        contact.currentIndex = keyIndex
        sequence = contact.currentSequence
        contact.currentSequence = sequence + 1
        contactManager.update(contact)
        timestamp = Int64(Date().timeIntervalSince1970 + 1000.0)

    }

    func encode(_ contact: Contact) -> [AnyHashable: Any] {

        var encoded = [AnyHashable: Any]()
        encoded["toId"] = publicId
        encoded["keyIndex"] = keyIndex
        encoded["sequence"] = sequence
        encoded["messageType"] = messageType
        encrypt(contact)
        encoded["body"] = ciphertext?.base64EncodedString()

        return encoded

    }

    func encrypt(_ contact: Contact) {

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
