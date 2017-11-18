//
//  CCSecureRandom.hpp
//  CryptoKitty_iOS
//
//  Created by Steve Brenneis on 12/8/16.
//  Copyright © 2016 CryptoKitty. All rights reserved.
//

#ifndef CCSecureRandom_h
#define CCSecureRandom_h

#include "SecureRandom.h"

class CCSecureRandom : public SecureRandom {

public:
    CCSecureRandom();
    ~CCSecureRandom();
    
private:
    CCSecureRandom(const CCSecureRandom& other);
    CCSecureRandom& operator =(const CCSecureRandom& other);

public:
    void nextBytes(coder::ByteArray& bytes);
    uint32_t nextInt();
    uint64_t nextLong();

};
    
#endif /* CCSecureRandom_hpp */
