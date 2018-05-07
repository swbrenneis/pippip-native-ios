//
//  UserVault.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 4/9/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import Foundation

@objc class UserVault: NSObject {

    var sessionState = SessionState()

    @objc func changePassphrase(oldPassphrase: String, newPassphrase: String) throws {

        let docsURLs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let docURL = docsURLs[0]
        let vaultsURL = docURL.appendingPathComponent("PippipVaults", isDirectory: true)
        let vaultURL = vaultsURL.appendingPathComponent(AccountManager.accountName!)
        let vaultData = try Data(contentsOf: vaultURL)

        try decode(vaultData, passphrase: oldPassphrase)
        let encoded = try encode(newPassphrase)
        try encoded.write(to: vaultURL)

    }

    static func validatePassphrase(_ passphrase: String) throws -> Bool {

        let docsURLs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let docURL = docsURLs[0]
        let vaultsURL = docURL.appendingPathComponent("PippipVaults", isDirectory: true)
        let vaultUrl = vaultsURL.appendingPathComponent(AccountManager.accountName!)
        let vaultData = try Data(contentsOf: vaultUrl)

        let digest = CKSHA256()
        let authData = passphrase.data(using: .utf8)
        let vaultKey = digest?.digest(authData!)
        
        let codec = CKGCMCodec(data: vaultData)!
        var error: NSError? = nil
        codec.decrypt(vaultKey, withAuthData: authData, withError: &error)
        
        return error == nil

    }

    @objc func decode(_ vaultData: Data, passphrase: String) throws {

        let digest = CKSHA256()
        let authData = passphrase.data(using: .utf8)
        let vaultKey = digest?.digest(authData!)

        let codec = CKGCMCodec(data: vaultData)!
        var error: NSError? = nil
        codec.decrypt(vaultKey, withAuthData: authData, withError: &error)
        if error != nil {
            throw error!
        }

        sessionState.publicId = codec.getString()
        sessionState.accountRandom = codec.getBlock()
        sessionState.genpass = codec.getBlock()
        sessionState.svpswSalt = codec.getBlock()
        sessionState.authData = codec.getBlock()
        sessionState.enclaveKey = codec.getBlock()
        sessionState.contactsKey = codec.getBlock()
        sessionState.userPrivateKeyPEM = codec.getString()
        sessionState.userPublicKeyPEM = codec.getString()

        let pem = CKPEMCodec()
        sessionState.userPrivateKey = pem.decodePrivateKey(sessionState.userPrivateKeyPEM)
        sessionState.userPublicKey = pem.decodePublicKey(sessionState.userPublicKeyPEM)

    }

    @objc func encode(_ passphrase: String) throws -> Data {

        let digest = CKSHA256()
        let authData = passphrase.data(using: .utf8)
        let vaultKey = digest?.digest(authData!)

        let codec = CKGCMCodec()
        codec.put(sessionState.publicId)
        codec.putBlock(sessionState.accountRandom)
        codec.putBlock(sessionState.genpass)
        codec.putBlock(sessionState.svpswSalt)
        codec.putBlock(sessionState.authData)
        codec.putBlock(sessionState.enclaveKey)
        codec.putBlock(sessionState.contactsKey)
        codec.put(sessionState.userPrivateKeyPEM)
        codec.put(sessionState.userPublicKeyPEM)

        return try codec.encrypt(vaultKey, withAuthData: authData)

    }

}
