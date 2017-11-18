#ifndef HMAC_H_INCLUDED
#define HMAC_H_INCLUDED

#include "ByteArray.h"

class Digest;

/*
 * Hash-based message authentication.
 * See RFC-2104 for details.
 */
class HMAC {

    private:
        HMAC();

    public:
        HMAC(Digest *digest);
        ~HMAC();

    private:
        HMAC(const HMAC& other);
        HMAC& operator= (const HMAC& other);

    public:
        bool authenticate(const coder::ByteArray& hmac);
        coder::ByteArray generateKey(unsigned bitsize);
        unsigned getDigestLength() const;
        coder::ByteArray getHMAC();
        void setKey(const coder::ByteArray& k);
        void setMessage(const coder::ByteArray& m);

    private:
        Digest *hash;
        coder::ByteArray K;
        coder::ByteArray ipad;
        coder::ByteArray opad;
        unsigned B;
        unsigned L;
        coder::ByteArray text;

};

#endif  // HMAC_H_INCLUDED
