//
//  SessionState.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 3/22/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import Foundation

class SessionStateActual: NSObject {

    // Server parameters
    var sessionId: Int32
    var authToken: Int64
    var accountRandom: Data?
    var serverPublicKey: CKRSAPublicKey?
    
    // Generated parameters
    var publicId: String?
    var genpass: Data?
    var svpswSalt: Data?    // Server vault passphrase salt.
    var authData: Data?
    var enclaveKey: Data?
    var contactsKey: Data?
    var userPrivateKey:  CKRSAPrivateKey?
    var userPrivateKeyPEM: String?
    var userPublicKey: CKRSAPublicKey?
    var userPublicKeyPEM: String?
    
    // Authentication parameters
    var clientAuthRandom: Data?
    var serverAuthRandom: Data?

    // Reauthorization latch
    var reauth: Bool?

    override init() {

        sessionId = 0;
        authToken = 0;

        super.init()

    }

}

