//
//  ParameterGenerator.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 3/22/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import Foundation

@objc class ParameterGenerator: SessionStateActual {

    @objc func generateParameters(_ accountName: String) {

        self.accountName = accountName
        
        let rnd: CKSecureRandom = CKSecureRandom()
        
        // Create generated password.
        self.genpass = rnd.nextBytes(20)
        
        // Create the server vault passphrase salt.
        self.svpswSalt = rnd.nextBytes(8)
        
        // Create GCM authentication data.
        let digest: CKSHA256 = CKSHA256()
        self.authData = digest.digest(self.genpass)
        
        // Create the message AES block cipher key.
        var keyRandom = rnd.nextBytes(32)
        self.enclaveKey = digest.digest(keyRandom)
        
        // Create the contact database AES block cipher key.
        keyRandom = rnd.nextBytes(32)
        self.contactsKey = digest.digest(keyRandom)
        
        // Create the user RSA keys.
        let gen: CKRSAKeyPairGenerator = CKRSAKeyPairGenerator()
        let pair: CKRSAKeyPair = gen.generateKeyPair(2048)
        let pem: CKPEMCodec  = CKPEMCodec()
        self.userPrivateKey = pair.privateKey
        self.userPublicKey = pair.publicKey
        self.userPrivateKeyPEM = pem.encode(pair.privateKey, with:pair.publicKey)
        self.userPublicKeyPEM = pem.encode(pair.publicKey)
        
        // Create the public ID.
        let sha1: CKSHA1 = CKSHA1()
        let data = accountName.data(using: String.Encoding.utf8)
        sha1.update(data)
        var now = Int64(Date.timeIntervalSinceReferenceDate) * 1000
        let timebytes = Data(bytes:&now, count:MemoryLayout<Int64>.size)
        sha1.update(timebytes)
        let seData = "secomm.org".data(using: String.Encoding.utf8)
        sha1.update(seData)
        self.publicId = HexCodec.hexString(sha1.digest())

    }

}
