//
//  Configurator.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 5/22/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit
import RealmSwift
import CocoaLumberjack

struct Entity {
    
    var publicId: String
    var directoryId: String?
    
    init() {
        publicId = ""
    }
    
    init(publicId: String, directoryId: String?) {
        self.publicId = publicId
        self.directoryId = directoryId
    }

}

class Configurator: NSObject {

    static let currentVersion: Float = 2.3

    var whitelist: [Entity] {
        return privateWhitelist
    }
    private var privateWhitelist = [Entity]()
    var authenticated: Bool {
        get {
            let config = getConfig()
            return config.authenticated
        }
        set {
            let config = getConfig()
            let realm = try! Realm()
            try! realm.write {
                config.authenticated = newValue
                config.version = Configurator.currentVersion
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
                config.version = Configurator.currentVersion
            }
        }
    }
    var showIgnoredContacts: Bool {
        get {
            let config = getConfig()
            return config.showIgnoredContacts
        }
        set {
            let config = getConfig()
            let realm = try! Realm()
            try! realm.write {
                config.showIgnoredContacts = newValue
                config.version = Configurator.currentVersion
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
                config.version = Configurator.currentVersion
            }
        }
    }
    var directoryId: String? {
        get {
            let config = getConfig()
            return config.directoryId
        }
        set {
            let config = getConfig()
            let realm = try! Realm()
            try! realm.write {
                config.directoryId = newValue
                config.version = Configurator.currentVersion
            }
        }
    }
    var statusUpdates: Int {
        get {
            let config = getConfig()
            return config.statusUpdates
        }
        set {
            let config = getConfig()
            let realm = try! Realm()
            try! realm.write {
                config.statusUpdates = newValue
                config.version = Configurator.currentVersion
            }
        }
    }
    var uuid: String {
        get {
            let config = getConfig()
            return config.uuid
        }
        set {
            let config = getConfig()
            let realm = try! Realm()
            try! realm.write {
                config.uuid = newValue
                config.version = Configurator.currentVersion
            }
        }
    }
    var autoAccept: Bool {
        get {
            let config = getConfig()
            return config.autoAccept
        }
        set {
            let config = getConfig()
            let realm = try! Realm()
            try! realm.write {
                config.autoAccept = newValue
                config.version = Configurator.currentVersion
            }
        }
    }
    var v2FirstRun: Bool {
        get {
            let config = getConfig()
            return config.v2FirstRun
        }
        set {
            let config = getConfig()
            let realm = try! Realm()
            try! realm.write {
                config.v2FirstRun = newValue
                config.version = Configurator.currentVersion
            }
        }
    }
    
    var sessionState = SessionState()

    func addWhitelistEntry(_ entity: Entity) throws {

        let config = getConfig()
        if privateWhitelist.isEmpty {
            try decodeWhitelist(config)
        }
        privateWhitelist.append(entity)
        try encodeWhitelist(config)
        
    }

    func decodeWhitelist(_ dbConfig: AccountConfig) throws {
        
        guard let dbWhitelist = dbConfig.whitelist else { return }
        let codec = CKGCMCodec(data: dbWhitelist)
        try codec.decrypt(sessionState.contactsKey!, withAuthData: sessionState.authData!)
        let count = codec.getLong()
        while whitelist.count < count {
            var entity = Entity()
            let directoryId = codec.getString()
            if directoryId.utf8.count > 0 {
                entity.directoryId = directoryId
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
                codec.put(entity.directoryId ?? "")
                codec.put(entity.publicId)
            }
            let encoded = codec.encrypt(sessionState.contactsKey!, withAuthData: sessionState.authData!)
            if encoded == nil {
                throw CryptoError(error: codec.lastError!)
            }
            try realm.write {
                config.whitelist = encoded
                config.version = Configurator.currentVersion
            }
        }
        else {
            try realm.write {
                config.whitelist = nil
                config.version = Configurator.currentVersion
            }
        }
        
    }

    private func getConfig() -> AccountConfig {
        
        do {
            let realm = try Realm()
            if let config = realm.objects(AccountConfig.self).first {
                return config
            }
            else {
                return AccountConfig()
            }
        }
        catch {
            DDLogError("Error retrieving configuration: \(error.localizedDescription)")
            return AccountConfig()
        }
        
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
            config.version = Configurator.currentVersion
        }
        
        return contactId

    }

    func newMessageId() -> Int64 {

        let config = getConfig()
        let messageId = config.currentMessageId
        
        let realm = try! Realm()
        try! realm.write {
            config.currentMessageId = messageId + 1
            config.version = Configurator.currentVersion
        }
        
        return messageId

    }

    func whitelistIndexOf(publicId: String) -> Int? {

        do {
            if privateWhitelist.count == 0 {
                try loadWhitelist()
            }
            return privateWhitelist.index(where: {(entry) -> Bool in
                return publicId == entry.publicId
            })
        }
        catch {
            DDLogError("Error loading whitelist: \(error.localizedDescription)")
            return nil
        }

    }

}
