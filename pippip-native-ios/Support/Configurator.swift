//
//  Configurator.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 5/22/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit
import RealmSwift

struct Entity {
    
    var publicId: String
    var nickname: String?
    
    init() {
        publicId = ""
    }
    
    init(publicId: String, nickname: String?) {
        self.publicId = publicId
        self.nickname = nickname
    }

}

class Configurator: NSObject {

    static let currentVersion: Float = 2.0

    var whitelist: [Entity] {
        return privateWhitelist
    }
    private var privateWhitelist = [Entity]()
    @objc var storeCleartextMessages: Bool {
        get {
            let config = getConfig()
            return config.storeCleartextMessages
        }
        set {
            let config = getConfig()
            let realm = try! Realm()
            try! realm.write {
                config.storeCleartextMessages = newValue
            }
        }
    }
    var useLocalAuth: Bool {
        get {
            let config = getConfig()
            return config.useLocalAuth
        }
        set {
            let config = getConfig()
            let realm = try! Realm()
            try! realm.write {
                config.useLocalAuth = newValue
            }
        }
    }
    var contactPolicy: String {
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

    var sessionState = SessionState()

    func addWhitelistEntry(_ entity: Entity) throws {

        let config = getConfig()
        if whitelist.isEmpty {
            try decodeWhitelist(config)
        }
        let index = whitelist.index(where: {(entry) -> Bool in
            return entity.publicId == entry.publicId
        })
        if index == NSNotFound {
            privateWhitelist.append(entity)
            try encodeWhitelist(config)
        }
        
    }

    func decodeWhitelist(_ config: AccountConfig) throws {
        
        let codec = CKGCMCodec(data: config.whitelist!)
        try codec.decrypt(sessionState.contactsKey!, withAuthData: sessionState.authData!)
        let count = codec.getLong()
        while whitelist.count < count {
            var entity = Entity()
            let nickname = codec.getString()
            if nickname.utf8.count > 0 {
                entity.nickname = nickname
            }
            entity.publicId = codec.getString()
            privateWhitelist.append(entity)
        }
        
    }
    
    func deleteWhitelistEntry(_ publicId: String) throws -> Int {

        let config = getConfig()
        if whitelist.isEmpty {
            try decodeWhitelist(config)
        }
        if let index = whitelist.index(where: { (entry) -> Bool in
            return publicId == entry.publicId
        }) {
            privateWhitelist.remove(at: index)
            try encodeWhitelist(config)
            return index
        }
        else {
            print("Whitelist entry for \(publicId) not found")
            return NSNotFound
        }

    }

    func encodeWhitelist(_ config: AccountConfig) throws {
        
        let realm = try Realm()
        if !whitelist.isEmpty {
            let codec = CKGCMCodec()
            codec.putLong(Int64(whitelist.count))
            for entity in whitelist {
                codec.put(entity.nickname ?? "")
                codec.put(entity.publicId)
            }
            let encoded = codec.encrypt(sessionState.contactsKey!, withAuthData: sessionState.authData!)
            if encoded == nil {
                throw CryptoError(error: codec.lastError!)
            }
            try realm.write {
                config.whitelist = encoded
            }
        }
        else {
            try realm.write {
                config.whitelist = nil
            }
        }
        
    }

    func getConfig() -> AccountConfig {
        
        let realm = try! Realm()
        let config = realm.objects(AccountConfig.self).first!
        return config
        
    }
    func loadWhitelist() throws {

        privateWhitelist.removeAll()
        let config = getConfig()
        guard let _ = config.whitelist else { return }
        try decodeWhitelist(config)

    }

    func newContactId() ->Int {

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

        return privateWhitelist.index(where: {(entry) -> Bool in
            return publicId == entry.publicId
        })

    }

}
