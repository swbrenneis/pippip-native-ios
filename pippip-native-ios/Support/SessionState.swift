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

    private static var actual: SessionStateActual?

    @objc var accountName: String {
        get {
            return SessionState.actual!.accountName!
        }
    }
    @objc var accountRandom: Data {
        get {
            return SessionState.actual!.accountRandom!
        }
        set (rnd) {
            SessionState.actual!.accountRandom = rnd
        }
    }
    @objc var authenticated: Bool {
        get {
            return SessionState.actual!.authenticated
        }
    }
    @objc var authData: Data {
        get {
            return SessionState.actual!.authData!
        }
    }
    @objc var authToken: UInt64 {
        get {
            return SessionState.actual!.authToken
        }
        set (token) {
            SessionState.actual!.authToken = token;
        }
    }
    @objc var clientAuthRandom: Data {
        get {
            return SessionState.actual!.clientAuthRandom!
        }
        set (rnd) {
            SessionState.actual!.clientAuthRandom = rnd
        }
    }
    @objc var contactsKey: Data {
        get {
            return SessionState.actual!.contactsKey!
        }
    }
    @objc var enclaveKey: Data {
        get {
            return SessionState.actual!.enclaveKey!
        }
    }
    @objc var genpass: Data {
        get {
            return SessionState.actual!.genpass!
        }
    }
    @objc var publicId: String {
        get {
            return SessionState.actual!.publicId!
        }
    }
    @objc var serverAuthRandom: Data {
        get {
            return SessionState.actual!.serverAuthRandom!
        }
        set (rnd) {
            SessionState.actual!.serverAuthRandom = rnd
        }
    }
    @objc var serverPublicKey: CKRSAPublicKey {
        get {
            return SessionState.actual!.serverPublicKey!
        }
        set (key) {
            SessionState.actual!.serverPublicKey = key
        }
    }
    @objc var sessionId: Int32 {
        get {
            return SessionState.actual!.sessionId
        }
        set (sessionId) {
            SessionState.actual!.sessionId = sessionId
        }
    }
    @objc var svpswSalt: Data {
        get {
            return SessionState.actual!.svpswSalt!
        }
    }
    @objc var userPrivateKey: CKRSAPrivateKey {
        get {
            return SessionState.actual!.userPrivateKey!
        }
    }
    @objc var userPublicKeyPEM: String {
        get {
            return SessionState.actual!.userPublicKeyPEM!
        }
    }

    @objc func setState(_ sessionState: SessionStateActual) {
        SessionState.actual = sessionState
    }

}
