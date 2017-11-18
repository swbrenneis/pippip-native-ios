#include "HMAC.h"
#include "IllegalStateException.h"
#include "BadParameterException.h"
#include "CCSecureRandom.h"
#include "Digest.h"

HMAC::HMAC(Digest *digest)
: hash(digest) {

    B = hash->getBlockSize();
    L = hash->getDigestLength();
    ipad = coder::ByteArray(B, 0x36);
    opad = coder::ByteArray(B, 0x5C);

}

HMAC::~HMAC() {

    delete hash;

}

bool HMAC::authenticate(const coder::ByteArray& hmac) {

    return getHMAC() == hmac;

}

/*
 * Generate an HMAC key. The key size will be rounded
 * to a byte boundary. The Key must be at least L bytes.
 */
coder::ByteArray HMAC::generateKey(unsigned bitsize) {

    if (bitsize / 8 < L) {
        throw BadParameterException("Invalid HMAC key size");
    }

    CCSecureRandom secure;
    K.setLength(bitsize / 8);
    secure.nextBytes(K);
    return K;

}

unsigned HMAC::getDigestLength() const {

    return hash->getDigestLength();

}

/*
 * Generate the HMAC.
 *
 * H(K XOR opad, H(K XOR ipad, text))
 *
 */
coder::ByteArray HMAC::getHMAC() {

    if (K.length() == 0) {
        throw IllegalStateException("HMAC key not set");
    }

    // Pad or truncate the key until it is B bytes.
    coder::ByteArray k;
    if (K.length() > B) {
        k = hash->digest(K);
    }
    else {
        k = K;
    }
    coder::ByteArray pad(B - k.length());
    k.append(pad);
    hash->reset();

    // First mask.
    coder::ByteArray i(k ^ ipad);
    i.append(text);
    coder::ByteArray h1(hash->digest(i));
    hash->reset();
    coder::ByteArray o(k ^ opad);
    o.append(h1);
    return hash->digest(o);

}

void HMAC::setKey(const coder::ByteArray& k) {

    if (k.length() < L) {
        throw BadParameterException("Invalid HMAC key");
    }

    K = k;

}

void HMAC::setMessage(const coder::ByteArray& m) {

    text = m;

}
