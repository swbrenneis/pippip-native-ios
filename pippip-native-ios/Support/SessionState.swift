//
//  SessionState.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 3/22/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import Foundation

@objc class SessionState: NSObject {

    // Authentication state parameters
    @objc var currentAccount: String?
    @objc var passphrase: String?
    private var auth: Bool
    
    // Server parameters
    @objc var sessionId: Int32
    @objc var authToken: UInt64
    @objc var accountRandom: Data?
    @objc var serverPublicKey: CKRSAPublicKey?
    
    // Generated parameters
    @objc var publicId: String?
    @objc var genpass: Data?
    @objc var svpswSalt: Data?    // Server vault passphrase salt.
    @objc var authData: Data?
    @objc var enclaveKey: Data?
    @objc var contactsKey: Data?
    @objc var userPrivateKey:  CKRSAPrivateKey?
    @objc var userPrivateKeyPEM: String?
    @objc var userPublicKey: CKRSAPublicKey?
    @objc var userPublicKeyPEM: String?
    
    // Authentication parameters
    @objc var clientAuthRandom: Data?
    @objc var serverAuthRandom: Data?

    @objc func authenticated() -> Bool {
        return auth;
    }

    @objc func authenticated(_ isAuth: Bool) {
        auth = isAuth;
    }

    @objc override init() {

        sessionId = 0;
        authToken = 0;
        auth = false;

        super.init()

    }

}

