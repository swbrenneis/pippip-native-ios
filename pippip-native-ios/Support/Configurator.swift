//
//  Configurator.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 5/22/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit

class Configurator: NSObject {

    var whitelist: [Entity] {
        return privateWhitelist
    }
    private var privateWhitelist = [Entity]()
    @objc var storeCleartextMessages: Bool {
        get {
            let config = database.getConfig()
            return config.cleartextMessages
        }
        set {
            database.storeCleartextMessages(newValue)
        }
    }
    var localAuth: Bool {
        get {
            let config = database.getConfig()
            return config.localAuth
        }
        set {
            database.useLocalAuth(newValue)
        }
    }
    var contactPolicy: String {
        get {
            let config = database.getConfig()
            return config.contactPolicy
        }
        set {
            database.setContactPolicy(newValue)
        }
    }
    @objc var nickname: String? {
        get {
            let config = database.getConfig()
            return config.nickname
        }
        set {
            database.setNickname(newValue)
        }
    }
    var database = ConfigDatabase()

    func addWhitelistEntry(_ entity: Entity) {

        var entry = [AnyHashable: Any]()
        entry["publicId"] = entity.publicId
        if entity.nickname != nil
        {
            entry["nickname"] = entity.nickname
        }
        database.addWhitelistEntry(entry)
        privateWhitelist.append(entity)
        
    }

    func deleteWhitelistEntry(_ publicId: String) -> Int {

        database.deleteWhitelistEntry(publicId)

        var index: Int = -1
        for i in 0..<privateWhitelist.count {
            if privateWhitelist[i].publicId == publicId {
                index = i
            }
        }
        assert(index >= 0)
        privateWhitelist.remove(at: index)
        return index

    }

    func loadWhitelist() {

        privateWhitelist.removeAll()
        database.loadWhitelist()
        for dict in database.whitelist {
            privateWhitelist.append(Entity(publicId: dict["publicId"] as! String,
                                           nickname: dict["nickname"] as? String))
        }
    }

    func newContactId() ->Int {

        return database.newContactId()

    }

    @objc func newMessageId() -> Int {

        return database.newMessageId()

    }

    func whitelistIndexOf(_ publicId: String) -> Int {

        return database.whitelistIndex(of: publicId)

    }

}
