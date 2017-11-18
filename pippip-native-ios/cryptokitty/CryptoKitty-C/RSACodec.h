//
//  RSACodec.h
//  CryptoKitty_iOS
//
//  Created by Steve Brenneis on 12/17/16.
//  Copyright © 2016 CryptoKitty. All rights reserved.
//

#ifndef RSACodec_h
#define RSACodec_h

#include "ByteStreamCodec.h"

class RSAPrivateKey;
class RSAPublicKey;

class RSACodec : public coder::ByteStreamCodec {

public:
    RSACodec();
    RSACodec(const coder::ByteArray& text);
    RSACodec(const RSACodec& other);
    ~RSACodec();

public:
    void decrypt(const RSAPrivateKey& privateKey);
    void encrypt(const RSAPublicKey& publicKey);
    const coder::ByteArray& toArray() const { return text; }


private:
    coder::ByteArray text;

};

#endif /* RSACodec_h */
