//
//  AccountDeleter.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 6/12/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import RealmSwift
import CocoaLumberjack

class AccountDeleter: NSObject {

    func deleteAccount() {
        
        deleteDirectoryId()
        let accountName = AccountSession.instance.accountName
        
        do {
            let realmURL = Realm.Configuration.defaultConfiguration.fileURL!
            let realmURLs = [
                realmURL,
                realmURL.appendingPathExtension("lock"),
                realmURL.appendingPathExtension("note"),
                realmURL.appendingPathExtension("management")
            ]
            for URL in realmURLs {
                try FileManager.default.removeItem(at: URL)
            }
        }
        catch {
            DDLogError("Error while deleting Realm files: \(error.localizedDescription)")
        }
        
        do {
            let docsURLs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            let docURL = docsURLs[0]
            let vaultsURL = docURL.appendingPathComponent("PippipVaults", isDirectory: true)
            let vaultUrl = vaultsURL.appendingPathComponent(accountName)
            try FileManager.default.removeItem(at: vaultUrl)
        }
        catch {
            DDLogError("Error while deleting user vault: \(error.localizedDescription)")
        }
        
    }

    func deleteDirectoryId() {

        let config = Configurator()
        if let directoryId = config.directoryId {
            ContactManager.instance.updateDirectoryId(newDirectoryId: nil, oldDirectoryId: directoryId)
        }

    }

}
