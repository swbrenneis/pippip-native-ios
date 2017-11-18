//
//  IosSecureRandom.cpp
//  CryptoKitty_iOS
//
//  Created by Steve Brenneis on 9/2/17.
//  Copyright © 2017 CryptoKitty. All rights reserved.
//

#include "IosSecureRandom.h"
#include "ByteArray.h"
#include "Unsigned32.h"
#include "Unsigned64.h"
#include <memory>
extern "C" {
#include <Security/Security.h>
}

IosSecureRandom::IosSecureRandom() {

}

void IosSecureRandom::nextBytes(coder::ByteArray& bytes) {

    size_t bytesLen = bytes.length();
    std::unique_ptr<uint8_t[]> buffer(new uint8_t[bytesLen]);
    int result = SecRandomCopyBytes(kSecRandomDefault, bytesLen, buffer.get());
    if (result == 0) {
        bytes  = coder::ByteArray(buffer.get(), bytesLen);
    }

}

uint32_t IosSecureRandom::nextInt() {

    coder::ByteArray bytes(4, 0);
    nextBytes(bytes);
    coder::Unsigned32 u32(bytes);
    return u32.getValue();

}

uint64_t IosSecureRandom::nextLong() {

    coder::ByteArray bytes(4, 0);
    nextBytes(bytes);
    coder::Unsigned64 u64(bytes);
    return u64.getValue();

}
    
void IosSecureRandom::setSeed(uint64_t seedValue) {

    // Nothing to do here

}

