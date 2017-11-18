//
//  GCMCodec.hpp
//  CryptoKitty_iOS
//
//  Created by Steve Brenneis on 12/18/16.
//  Copyright © 2016 CryptoKitty. All rights reserved.
//

#ifndef GCMCodec_hpp
#define GCMCodec_hpp

#include "ByteArray.h"
#include "ByteStreamCodec.h"

class GCMCodec : public coder::ByteStreamCodec {

public:
    GCMCodec();
    GCMCodec(const coder::ByteArray& ciphertext);
    ~GCMCodec();

public:
    void decrypt(const coder::ByteArray& key, const coder::ByteArray& ad);
    void encrypt(const coder::ByteArray& key, const coder::ByteArray& ad);
    const coder::ByteArray& toArray() const { return text; }

private:
    coder::ByteArray text;

};

#endif /* GCMCodec_hpp */
