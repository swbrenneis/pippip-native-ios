//
//  AccountManager.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 5/5/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit
import RealmSwift

class AccountManager: NSObject {

    static let CURRENT_VERSION: Float = 1.2
    @objc static var accountName: String?

    func loadAccount() throws ->String? {

        let fileManager = FileManager.default
        let documentDirectory = try fileManager.url(for: .documentDirectory,
                                                    in: .userDomainMask,
                                                    appropriateFor:nil,
                                                    create:false)
        let vaultsURL = documentDirectory.appendingPathComponent("PippipVaults")
        let path = vaultsURL.path as NSString
        if !fileManager.fileExists(atPath: path.expandingTildeInPath) {
            try fileManager.createDirectory(at: vaultsURL, withIntermediateDirectories: false, attributes: nil)
        }
        let vaults = try fileManager.contentsOfDirectory(at: vaultsURL,
                                                         includingPropertiesForKeys: nil,
                                                         options: .skipsHiddenFiles)
        if !vaults.isEmpty {
            AccountManager.accountName = vaults[0].lastPathComponent
            return AccountManager.accountName
        }
        else {
            return nil
        }

    }

    func loadConfig() {

        setRealmConfiguration()
        let realm = try! Realm()
        let config = realm.objects(AccountConfig.self).first
        print("AccountConfig version \(config!.version)")
        if config!.version < 1.1 {
            try! realm.write {
                config!.localAuth = true
            }
        }

    }

    func setDefaultConfig() {

        let config = AccountConfig()
        config.accountName = AccountManager.accountName!
        config.version = AccountManager.CURRENT_VERSION
        do {
            let realm = try Realm()
            try realm.write {
                realm.add(config)
            }
        }
        catch {
            print("Error writing initial config to database: \(error)")
        }

    }

    func setRealmConfiguration() {

        var realmConfig = Realm.Configuration()
        realmConfig.fileURL = realmConfig.fileURL?.deletingLastPathComponent()
                                                    .appendingPathComponent("\(AccountManager.accountName!).realm")
        realmConfig.schemaVersion = 10
        realmConfig.migrationBlock = { (migration, oldSchemaVersion) in
            if oldSchemaVersion < 10 {
                migration.enumerateObjects(ofType: DatabaseMessage.className()) { (oldObject, newObject) in
                    newObject!["originating"] = oldObject!["sent"]
                }
                migration.enumerateObjects(ofType: AccountConfig.className()) { (oldObject, newObject) in
                    newObject!["currentContactId"] = oldObject!["contactId"]
                    newObject!["currentMessageId"] = oldObject!["messageId"]
                    newObject!["contactPolicy"] = oldObject!["contactPolicy"]
                }
            }
        }
        Realm.Configuration.defaultConfiguration = realmConfig

    }
    
}
