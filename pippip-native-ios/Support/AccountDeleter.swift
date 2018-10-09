//
//  AccountDeleter.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 6/12/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import RealmSwift

class AccountDeleter: NSObject {

    func deleteAccount() throws {

        deleteDirectoryId()
        let authenticator = Authenticator()
        authenticator.logout()
        let accountName = AccountSession.instance.accountName

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
        let docsURLs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let docURL = docsURLs[0]
        let vaultsURL = docURL.appendingPathComponent("PippipVaults", isDirectory: true)
        let vaultUrl = vaultsURL.appendingPathComponent(accountName)
        try FileManager.default.removeItem(at: vaultUrl)

    }

    func deleteDirectoryId() {

        let config = Configurator()
        if let directoryId = config.directoryId {
            ContactManager.instance.updateDirectoryId(newDirectoryId: nil, oldDirectoryId: directoryId)
        }

    }

}
