//
//  SessionState.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 4/9/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit

/*
 * This is a dependency injection proxy class.
 */
class SessionState: NSObject {

    private static var actual = SessionStateActual()

    @objc var accountRandom: Data? {
        get {
            return SessionState.actual.accountRandom
        }
        set {
            SessionState.actual.accountRandom = newValue
        }
    }
    @objc var authData: Data? {
        get {
            return SessionState.actual.authData
        }
        set {
            SessionState.actual.authData = newValue
        }
    }
    @objc var authToken: Int64 {
        get {
            return SessionState.actual.authToken
        }
        set {
            SessionState.actual.authToken = newValue
        }
    }
    @objc var clientAuthRandom: Data? {
        get {
            return SessionState.actual.clientAuthRandom
        }
        set {
            SessionState.actual.clientAuthRandom = newValue
        }
    }
    @objc var contactsKey: Data? {
        get {
            return SessionState.actual.contactsKey
        }
        set {
            SessionState.actual.contactsKey = newValue
        }
    }
    @objc var enclaveKey: Data? {
        get {
            return SessionState.actual.enclaveKey
        }
        set {
            SessionState.actual.enclaveKey = newValue
        }
    }
    @objc var genpass: Data? {
        get {
            return SessionState.actual.genpass
        }
        set {
            SessionState.actual.genpass = newValue
        }
    }
    @objc var publicId: String? {
        get {
            return SessionState.actual.publicId
        }
        set {
            SessionState.actual.publicId = newValue
        }
    }
    @objc var serverAuthRandom: Data? {
        get {
            return SessionState.actual.serverAuthRandom
        }
        set {
            SessionState.actual.serverAuthRandom = newValue
        }
    }
    @objc var serverPublicKey: CKRSAPublicKey? {
        get {
            return SessionState.actual.serverPublicKey
        }
        set {
            SessionState.actual.serverPublicKey = newValue
        }
    }
    @objc var sessionId: Int32 {
        get {
            return SessionState.actual.sessionId
        }
        set {
            SessionState.actual.sessionId = newValue
        }
    }
    @objc var svpswSalt: Data? {
        get {
            return SessionState.actual.svpswSalt
        }
        set {
            SessionState.actual.svpswSalt = newValue
        }
    }
    @objc var userPrivateKey: CKRSAPrivateKey? {
        get {
            return SessionState.actual.userPrivateKey
        }
        set {
            SessionState.actual.userPrivateKey = newValue
        }
    }
    @objc var userPublicKeyPEM: String? {
        get {
            return SessionState.actual.userPublicKeyPEM
        }
        set {
            SessionState.actual.userPublicKeyPEM = newValue
        }
    }
    @objc var userPrivateKeyPEM: String? {
        get {
            return SessionState.actual.userPrivateKeyPEM
        }
        set {
            SessionState.actual.userPrivateKeyPEM = newValue
        }
    }
    
    @objc var userPublicKey: CKRSAPublicKey? {
        get {
            return SessionState.actual.userPublicKey
        }
        set {
            SessionState.actual.userPublicKey = newValue
        }
    }

    @objc var reauth: Bool {
        get {
            return SessionState.actual.reauth ?? false
        }
        set {
            SessionState.actual.reauth = newValue
        }
    }

}
