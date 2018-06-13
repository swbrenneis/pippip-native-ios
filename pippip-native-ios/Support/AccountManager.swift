//
//  AccountManager.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 6/10/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit
import RealmSwift

class AccountManager: NSObject {

    static let production = true
    static var accountName: String?

    func loadAccount() throws {
        
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
        }
        
    }

    func loadConfig() {
        
        setRealmConfiguration()
        let realm = try! Realm()
        let config = realm.objects(AccountConfig.self).first
        print("AccountConfig version \(config!.version)")
        
    }

    func setDefaultConfig() {
        
        let config = AccountConfig()
        config.accountName = AccountManager.accountName!
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
        realmConfig.schemaVersion = 13
        realmConfig.migrationBlock = { (migration, oldSchemaVersion) in
            // Schema version 13 is Realm Swift
            if oldSchemaVersion < 13 {
                migration.enumerateObjects(ofType: DatabaseMessage.className()) { (oldObject, newObject) in
                    newObject!["originating"] = oldObject!["sent"]
                }
                migration.enumerateObjects(ofType: AccountConfig.className()) { (oldObject, newObject) in
                    newObject!["currentContactId"] = oldObject!["contactId"]
                    newObject!["currentMessageId"] = oldObject!["messageId"]
                    newObject!["storeCleartextMessages"] = oldObject!["cleartextMessages"]
                    newObject!["useLocalAuth"] = oldObject!["localAuth"]
                }
            }
        }
        Realm.Configuration.defaultConfiguration = realmConfig
        
    }

}
