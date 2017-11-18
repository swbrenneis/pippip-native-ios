//
//  RSACodec.cpp
//  CryptoKitty_iOS
//
//  Created by Steve Brenneis on 12/17/16.
//  Copyright © 2016 CryptoKitty. All rights reserved.
//

#include "RSACodec.h"
#include "RSAPrivateKey.h"
#include "RSAPublicKey.h"
#include "OAEPrsaes.h"
#include "DecryptionException.h"
#include "BadParameterException.h"
#include "EncodingException.h"
#include "CCSecureRandom.h"

RSACodec::RSACodec() {

}

RSACodec::RSACodec(const coder::ByteArray& txt)
: text(txt) {

}

RSACodec::~RSACodec() {

}

void RSACodec::decrypt(const RSAPrivateKey& privateKey) {

    try {
        OAEPrsaes cipher(OAEPrsaes::sha256);
        stream = cipher.decrypt(privateKey, text);
    }
    catch (DecryptionException& e) {
        throw EncodingException(e);
    }

}

void RSACodec::encrypt(const RSAPublicKey& publicKey) {

    try {
        OAEPrsaes cipher(OAEPrsaes::sha256);
        coder::ByteArray seed(32, 0);
        CCSecureRandom rnd;
        rnd.nextBytes(seed);
        cipher.setSeed(seed);
        text = cipher.encrypt(publicKey, stream);
    }
    catch (BadParameterException& e) {
        throw EncodingException(e);
    }

}

