//
//  UserVault.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 4/9/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import Foundation

@objc class UserVault: NSObject {

    var sessionStateActual: SessionStateActual

    @objc override init() {
        sessionStateActual = SessionStateActual()
        super.init()
    }

    @objc init(with state: SessionStateActual) {
        sessionStateActual = state
        super.init()
    }

    @objc func changePassphrase(oldPassphrase: String, newPassphrase: String) throws {

        let sessionState = SessionState()
        let docsURLs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let docURL = docsURLs[0]
        let vaultsURL = docURL.appendingPathComponent("PippipVaults", isDirectory: true)
        let vaultURL = vaultsURL.appendingPathComponent(sessionState.accountName)
        let vaultData = try Data(contentsOf: vaultURL)

        try decode(vaultData, passphrase: oldPassphrase)
        let encoded = try encode(newPassphrase)
        try encoded.write(to: vaultURL)

    }

    static func validatePassphrase(_ passphrase: String) throws -> Bool {

        let sessionState = SessionState()
        let docsURLs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let docURL = docsURLs[0]
        let vaultsURL = docURL.appendingPathComponent("PippipVaults", isDirectory: true)
        let vaultUrl = vaultsURL.appendingPathComponent(sessionState.accountName)
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

        sessionStateActual.publicId = codec.getString()
        sessionStateActual.accountRandom = codec.getBlock()
        sessionStateActual.genpass = codec.getBlock()
        sessionStateActual.svpswSalt = codec.getBlock()
        sessionStateActual.authData = codec.getBlock()
        sessionStateActual.enclaveKey = codec.getBlock()
        sessionStateActual.contactsKey = codec.getBlock()
        sessionStateActual.userPrivateKeyPEM = codec.getString()
        sessionStateActual.userPublicKeyPEM = codec.getString()

        let pem = CKPEMCodec()
        sessionStateActual.userPrivateKey = pem.decodePrivateKey(sessionStateActual.userPrivateKeyPEM)
        sessionStateActual.userPublicKey = pem.decodePublicKey(sessionStateActual.userPublicKeyPEM)

    }

    @objc func encode(_ passphrase: String) throws -> Data {

        let digest = CKSHA256()
        let authData = passphrase.data(using: .utf8)
        let vaultKey = digest?.digest(authData!)

        let codec = CKGCMCodec()
        codec.put(sessionStateActual.publicId)
        codec.putBlock(sessionStateActual.accountRandom)
        codec.putBlock(sessionStateActual.genpass)
        codec.putBlock(sessionStateActual.svpswSalt)
        codec.putBlock(sessionStateActual.authData)
        codec.putBlock(sessionStateActual.enclaveKey)
        codec.putBlock(sessionStateActual.contactsKey)
        codec.put(sessionStateActual.userPrivateKeyPEM)
        codec.put(sessionStateActual.userPublicKeyPEM)

        return try codec.encrypt(vaultKey, withAuthData: authData)

    }

}
