//
//  TextMessage.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 4/3/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit

class TextMessage: Message {

    static let currentVersion: Float = 1.0
    @objc var version: Float = 0
    @objc var cleartext: String?

    override init(serverMessage: [AnyHashable: Any]) {

        version = TextMessage.currentVersion

        super.init(serverMessage: serverMessage)

    }

    override init(text: String, contact: Contact) {

        version = TextMessage.currentVersion
        cleartext = text

        super.init(text: text, contact: contact)

        messageType = "user text"

    }

    @objc override init(dbMessage: DatabaseMessage) {
        
        version = dbMessage.version
        cleartext = dbMessage.cleartext
        
        super.init(dbMessage: dbMessage)

    }

    @objc func decrypt(_ noNotify: Bool = false) {

        if cleartext == nil {
            guard let _ = ciphertext else { return }
            let contact = contactManager.getContactById(contactId)!
            let ivGen = CKIVGenerator()
            let iv = ivGen.generate(Int(sequence), withNonce: contact.nonce)
            let codec = CKGCMCodec(data: ciphertext)!
            codec.setIV(iv)
            var error: NSError? = nil
            codec.decrypt(contact.messageKeys![keyIndex], withAuthData: contact.authData,
                          withError: &error)
            if let _ = error {
                let message = error?.debugDescription ?? "Unknown"
                print("Error decrypting message - \(message)")
            }
            else {
                self.cleartext = codec.getString()
            }
        }
        if !noNotify {
            NotificationCenter.default.post(name: Notifications.CleartextAvailable, object: self)
        }

    }

    @objc override func encodeForDatabase() -> DatabaseMessage {

        let dbMessage = super.encodeForDatabase()
        dbMessage.version = version
        if config.getCleartextMessages() {
            dbMessage.cleartext = cleartext
        }
        return dbMessage

    }

    @objc func encrypt() throws {

        let contact = contactManager.getContactById(contactId)!
        let ivGen = CKIVGenerator()
        let iv = ivGen.generate(Int(sequence), withNonce: contact.nonce)
        let codec = CKGCMCodec()
        codec.setIV(iv)
        codec.put(cleartext)
        try ciphertext = codec.encrypt(contact.messageKeys![keyIndex], withAuthData: contact.authData)
        
    }

}

