//
//  CCSecureRandom.cpp
//  CryptoKitty_iOS
//
//  Created by Steve Brenneis on 12/8/16.
//  Copyright © 2016 CryptoKitty. All rights reserved.
//

#include "CCSecureRandom.h"
#include "Unsigned32.h"
#include "Unsigned64.h"
#include <CommonCrypto/CommonCrypto.h>
#include <CommonCrypto/CommonRandom.h>

CCSecureRandom::CCSecureRandom() {
    
}

CCSecureRandom::~CCSecureRandom() {
    
}

/*
 * Returns the next 32 bits of entropy.
 */
uint32_t CCSecureRandom::nextInt() {
    
    coder::ByteArray bytes(4);
    nextBytes(bytes);
    coder::Unsigned32 u32(bytes);
    return u32.getValue();
    
}

/*
 * Returns the next 64 bits of entropy.
 */
uint64_t CCSecureRandom::nextLong() {
    
    coder::ByteArray bytes(8);
    nextBytes(bytes);
    coder::Unsigned64 u64(bytes);
    return u64.getValue();
    
}

/*
 * Fills the ByteArray with random bytes. The arra sizeis
 * determines the number of bytes generated.
 */
void CCSecureRandom::nextBytes(coder::ByteArray& bytes) {
    
    size_t size = bytes.length();
    std::unique_ptr<uint8_t[]> rbytes(new uint8_t[size]);
    CCRandomGenerateBytes(rbytes.get(), size);
    bytes.copy(0, rbytes.get(), 0, size);
    
}
