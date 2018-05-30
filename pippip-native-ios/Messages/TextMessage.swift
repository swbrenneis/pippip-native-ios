//
//  TextMessage.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 4/3/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit
import DataCompression

class TextMessage: Message {

    @objc var cleartext: String?

    init(text: String, contact: Contact) {

        cleartext = text

        super.init(contact: contact)

        messageType = "user text"
        read = true
        version = Message.currentVersion

    }

    @objc override init(dbMessage: DatabaseMessage) {
        
        cleartext = dbMessage.cleartext
        
        super.init(dbMessage: dbMessage)

    }
    
    override init(serverMessage: [AnyHashable : Any]) {

        super.init(serverMessage: serverMessage)

    }

    func compress(_ text: String) -> Data? {

        let decompressed = text.data(using: .utf8)
        let compressed = decompressed?.compress(withAlgorithm: .LZMA)
        print("Uncompressed size \(text.utf8.count)")
        print("Compressed size \(compressed?.count ?? 0)")
        return compressed

    }

    func decompress(_ compressed: Data) -> String? {

        let decompressed = compressed.decompress(withAlgorithm: .LZMA)
        return String(data: decompressed!, encoding: .utf8)

    }

    @objc func decrypt(noNotify: Bool = false) {

        if cleartext == nil {
            guard let _ = ciphertext else { return }
            if let contact = contactManager.getContactById(contactId) {
                let ivGen = CKIVGenerator()
                let iv = ivGen.generate(Int(sequence), withNonce: contact.nonce!)
                let codec = CKGCMCodec(data: ciphertext!)
                codec.setIV(iv)
                do {
                    try codec.decrypt(contact.messageKeys![keyIndex], withAuthData: contact.authData!)
                    if compressed {
                        let block = codec.getBlock()
                        self.cleartext = decompress(block)
                        print("Compressed size \(block.count)")
                        print("Cleartext length \(self.cleartext!.utf8.count)")
                    }
                    else {
                        self.cleartext = codec.getString()
                    }
                }
                catch {
                    print("Error decrypting message - \(error)")
                    cleartext = "Encryption error"
                }
            }
            else {
                print("Invalid contact ID in message")
            }
        }
        if cleartext == nil {
            cleartext = "Decryption failed"
        }
        if !noNotify {
            NotificationCenter.default.post(name: Notifications.CleartextAvailable, object: self)
        }

    }

    @objc override func encodeForDatabase() -> DatabaseMessage {

        let dbMessage = super.encodeForDatabase()
        if config.storeCleartextMessages {
            dbMessage.cleartext = cleartext
        }
        return dbMessage

    }

    @objc func encrypt() throws {

        let contact = contactManager.getContactById(contactId)!
        let ivGen = CKIVGenerator()
        let iv = ivGen.generate(Int(sequence), withNonce: contact.nonce!)
        let codec = CKGCMCodec()
        codec.setIV(iv)
        if cleartext!.utf8.count > 500 {
            codec.putBlock(compress(cleartext!))
            compressed = true
        }
        else {
            codec.put(cleartext!)
            compressed = false
        }
        try ciphertext = codec.encrypt(contact.messageKeys![keyIndex], withAuthData: contact.authData)
        
    }

}

