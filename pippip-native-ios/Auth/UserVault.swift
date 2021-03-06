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

    @objc func changePassphrase(accountName: String, oldPassphrase: String, newPassphrase: String) throws {

        let docsURLs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let docURL = docsURLs[0]
        let vaultsURL = docURL.appendingPathComponent("PippipVaults", isDirectory: true)
        let vaultURL = vaultsURL.appendingPathComponent(accountName)
        let vaultData = try Data(contentsOf: vaultURL)

        try decode(vaultData, passphrase: oldPassphrase)
        let encoded = try encode(newPassphrase)
        try encoded.write(to: vaultURL)

    }

    static func validatePassphrase(passphrase: String) -> Bool {

        let docsURLs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let docURL = docsURLs[0]
        let vaultsURL = docURL.appendingPathComponent("PippipVaults", isDirectory: true)
        let vaultUrl = vaultsURL.appendingPathComponent(AccountSession.instance.accountName)
        
        do {
            let vaultData = try Data(contentsOf: vaultUrl)            
            let digest = CKSHA256()
            guard let authData = passphrase.data(using: .utf8) else { return false }
            let vaultKey = digest.digest(authData)
            let codec = CKGCMCodec(data: vaultData)
            try codec.decrypt(vaultKey, withAuthData: authData)
            return true
        }
        catch {
            return false
        }
        
    }

    @objc func decode(_ vaultData: Data, passphrase: String) throws {

        let digest = CKSHA256()
        guard let authData = passphrase.data(using: .utf8)
            else { throw CryptoError(error: "Invalid passphrase encoding") }
        let vaultKey = digest.digest(authData)

        let codec = CKGCMCodec(data: vaultData)
        try codec.decrypt(vaultKey, withAuthData: authData)

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
        guard let authData = passphrase.data(using: .utf8)
            else { throw CryptoError(error: "Invalid passphrase encoding") }
        let vaultKey = digest.digest(authData)

        let codec = CKGCMCodec()
        codec.put(sessionState.publicId!)
        codec.putBlock(sessionState.accountRandom!)
        codec.putBlock(sessionState.genpass!)
        codec.putBlock(sessionState.svpswSalt!)
        codec.putBlock(sessionState.authData!)
        codec.putBlock(sessionState.enclaveKey!)
        codec.putBlock(sessionState.contactsKey!)
        codec.put(sessionState.userPrivateKeyPEM!)
        codec.put(sessionState.userPublicKeyPEM!)

        guard let encoded = codec.encrypt(vaultKey, withAuthData: authData)
            else { throw CryptoError(error: codec.lastError!)}
        return encoded

    }

}
