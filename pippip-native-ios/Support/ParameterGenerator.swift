//
//  ParameterGenerator.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 3/22/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import Foundation

@objc class ParameterGenerator: NSObject {

    private var sessionState = SessionState()

    func generateParameters(_ accountName: String) {

        let rnd: CKSecureRandom = CKSecureRandom()
        
        // Create generated password.
        sessionState.genpass = rnd.nextBytes(20)
        
        // Create the server vault passphrase salt.
        sessionState.svpswSalt = rnd.nextBytes(8)
        
        // Create GCM authentication data.
        let digest: CKSHA256 = CKSHA256()
        sessionState.authData = digest.digest(sessionState.genpass!)
        
        // Create the enclave AES block cipher key.
        var keyRandom = rnd.nextBytes(32)
        sessionState.enclaveKey = digest.digest(keyRandom)
        
        // Create the contact database AES block cipher key.
        keyRandom = rnd.nextBytes(32)
        sessionState.contactsKey = digest.digest(keyRandom)
        
        // Create the user RSA keys.
        let gen: CKRSAKeyPairGenerator = CKRSAKeyPairGenerator()
        let pair: CKRSAKeyPair = gen.generateKeyPair(2048)
        let pem: CKPEMCodec  = CKPEMCodec()
        sessionState.userPrivateKey = pair.privateKey
        sessionState.userPublicKey = pair.publicKey
        sessionState.userPrivateKeyPEM = pem.encode(pair.privateKey, with:pair.publicKey)
        sessionState.userPublicKeyPEM = pem.encode(pair.publicKey)
        
        // Create the public ID.
        let sha1: CKSHA1 = CKSHA1()
        let data = accountName.data(using: String.Encoding.utf8)
        sha1.update(data)
        var now = Int64(Date.timeIntervalSinceReferenceDate) * 1000
        let timebytes = Data(bytes:&now, count:MemoryLayout<Int64>.size)
        sha1.update(timebytes)
        let seData = "secomm.org".data(using: String.Encoding.utf8)
        sha1.update(seData)
        sessionState.publicId = HexCodec.hexString(sha1.digest())

        NotificationCenter.default.post(name: Notifications.ParametersGenerated, object: nil)

    }

}
