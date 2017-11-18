//
//  IosSecureRandom.h
//  CryptoKitty_iOS
//
//  Created by Steve Brenneis on 9/2/17.
//  Copyright © 2017 CryptoKitty. All rights reserved.
//

#ifndef IosSecureRandom_h
#define IosSecureRandom_h

#include "SecureRandom.h"

class IosSecureRandom : public SecureRandom {

public:
    IosSecureRandom();
    ~IosSecureRandom() {}

private:
    IosSecureRandom(const IosSecureRandom& other);
    IosSecureRandom& operator = (const IosSecureRandom& other);

public:
    void nextBytes(coder::ByteArray& bytes);
    uint32_t nextInt();
    uint64_t nextLong();
    void setSeed(uint64_t seedValue);

};

#endif /* IosSecureRandom_h */
