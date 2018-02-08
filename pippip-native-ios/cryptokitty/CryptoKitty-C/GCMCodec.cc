//
//  GCMCodec.cpp
//  CryptoKitty_iOS
//
//  Created by Steve Brenneis on 12/18/16.
//  Copyright © 2016 CryptoKitty. All rights reserved.
//

#include "GCMCodec.h"
#include "GCM.h"
#include "AES.h"
#include "CCSecureRandom.h"
#include "EncodingException.h"
#include "BadParameterException.h"
#include "AuthenticationException.h"
#include "OutOfRangeException.h"

GCMCodec::GCMCodec() {
    
}

GCMCodec::GCMCodec(const coder::ByteArray& ciphertext)
: text(ciphertext) {
    
}

GCMCodec::~GCMCodec() {
    
}

void GCMCodec::decrypt(const coder::ByteArray& key, const coder::ByteArray& ad) {

    coder::ByteArray ciphertext(text.range(0, text.length() - 12));
    if (iv.length() == 0) {
        // The IV is the last 12 bytes of the provided text.
        iv = text.range(text.length() - 12);
    }

    try {
        GCM gcm(new AES(AES::AES256), true);    // Auth tag is appended
        gcm.setIV(iv);
        gcm.setAuthenticationData(ad);
        stream = gcm.decrypt(ciphertext, key);
    }
    catch (BadParameterException& e) {
        throw EncodingException(e);
    }
    catch (AuthenticationException& e) {
        throw EncodingException(e);
    }
    catch (coder::OutOfRangeException& e) {
        throw EncodingException("Array parameters out of range");
    }
    
}

void GCMCodec::encrypt(const coder::ByteArray& key, const coder::ByteArray& ad) {

    if (iv.length() == 0) {
        iv.setLength(12);
        CCSecureRandom rnd;
        rnd.nextBytes(iv);
    }

    try {
        GCM gcm(new AES(AES::AES256), true);    // Append the auth tag.
        gcm.setIV(iv);
        gcm.setAuthenticationData(ad);
        text = gcm.encrypt(stream, key);
        text.append(iv);                        // Append the IV
    }
    catch (BadParameterException& e) {
        throw EncodingException(e);
    }
    catch (AuthenticationException& e) {
        throw EncodingException("Authentication failer");
    }
    catch (coder::OutOfRangeException& e) {
        throw EncodingException("Array parameters out of range");
    }

}

void GCMCodec::setIV(const coder::ByteArray &ivSet) {

    iv = ivSet;

}
