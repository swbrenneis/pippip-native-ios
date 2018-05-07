//
//  Configurator.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 5/5/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit
import RealmSwift

public struct Entity {

    var publicId: String!
    var nickname: String?

}

class Configurator: NSObject {

    static let CURRENT_VERSION: Float = 1.2

    var whitelist = [Entity]()
    var sessionState = SessionState()
    var storeCleartextMessages: Bool {
        get {
            let config = getConfig()
            return config.cleartextMessages
        }
        set {
            let config = getConfig()
            let realm = try! Realm()
            try! realm.write {
                config.cleartextMessages = newValue
            }
        }
    }
    @objc var contactPolicy: String {
        get {
            let config = getConfig()
            return config.contactPolicy
        }
        set {
            let config = getConfig()
            let realm = try! Realm()
            try! realm.write {
                config.contactPolicy = newValue
            }
        }
    }
    var useLocalAuth: Bool {
        get {
            let config = getConfig()
            return config.localAuth
        }
        set {
            let config = getConfig()
            let realm = try! Realm()
            try! realm.write {
                config.localAuth = newValue
            }
        }
    }
    @objc var nickname: String? {
        get {
            let config = getConfig()
            return config.nickname
        }
        set {
            let config = getConfig()
            let realm = try! Realm()
            try! realm.write {
                config.nickname = newValue
            }
        }
    }

    func addWhitelistEntry(entity: Entity) throws {

        let config = getConfig()
        if whitelist.isEmpty {
            try decodeWhitelist(config)
        }
        let index = whitelist.index(where: {(entry) -> Bool in
            return entity.publicId == entry.publicId
        })
        if index == NSNotFound {
            whitelist.append(entity)
            try encodeWhitelist(config)
        }
        
    }

    private func decodeWhitelist(_ config: AccountConfig) throws {

        guard let _ = config.whitelist else { return }
        let codec = CKGCMCodec(data: config.whitelist!)!
        var error: NSError? = nil
        codec.decrypt(sessionState.contactsKey, withAuthData: sessionState.authData, withError: &error)
        if let _ = error {
            let message = error?.debugDescription ?? "Unknown"
            print("Error decrypting whitelist: \(message)")
        }
        else {
            let count = codec.getInt()
            while whitelist.count < count {
                var entity = Entity()
                let nickname = codec.getString()!
                if nickname.utf8.count > 0 {
                    entity.nickname = nickname
                }
                entity.publicId = codec.getString()!
                whitelist.append(entity)
            }
        }

    }

    func deleteWhitelistEntry(_ publicId: String) throws {

        let config = getConfig()
        if whitelist.isEmpty {
            try decodeWhitelist(config)
        }
        if let index = whitelist.index(where: { (entry) -> Bool in
            return publicId == entry.publicId
        }) {
            whitelist.remove(at: index)
            try encodeWhitelist(config)
        }
        else {
            print("Whitelist entry for \(publicId) not found")
        }
        
    }

    private func encodeWhitelist(_ config: AccountConfig) throws {

        let realm = try Realm()
        if !whitelist.isEmpty {
            let codec = CKGCMCodec()
            codec.put(Int32(whitelist.count))
            for entity in whitelist {
                codec.put(entity.nickname ?? "")
                codec.put(entity.publicId)
            }
            try realm.write {
                try config.whitelist = codec.encrypt(sessionState.contactsKey, withAuthData: sessionState.authData)
            }
        }
        else {
            try realm.write {
                config.version = Configurator.CURRENT_VERSION
                config.whitelist = nil
            }
        }

    }

    private func getConfig() -> AccountConfig {

        let realm = try! Realm()
        let config = realm.objects(AccountConfig.self).first!
        return config

    }

    func loadWhitelist() throws {

        let config = getConfig()
        try decodeWhitelist(config)

    }

    func newContactId() -> Int32 {

        let config = getConfig()
        let contactId = config.currentContactId
        
        let realm = try! Realm()
        try! realm.write {
            config.currentContactId = contactId + 1
        }

        return contactId

    }

    func newMessageId() -> Int64 {

        let config = getConfig()
        let messageId = config.currentMessageId
        
        let realm = try! Realm()
        try! realm.write {
            config.currentMessageId = messageId + 1
        }
        
        return messageId
        
    }

    func whitelistIndexOf(_ publicId: String) -> Int? {

        return whitelist.index(where: {(entry) -> Bool in
            return publicId == entry.publicId
        })

    }

}
