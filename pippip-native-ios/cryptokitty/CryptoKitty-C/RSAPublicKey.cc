#include "RSAPublicKey.h"

RSAPublicKey::RSAPublicKey(const BigInteger& n, const BigInteger& e)
: PublicKey("RSA"),
  exp(e),
  mod(n) {

      bitLength = mod.bitLength();

}

RSAPublicKey::~RSAPublicKey() {
}

size_t RSAPublicKey::getBitLength() const {

    return bitLength;

}

const BigInteger& RSAPublicKey::getPublicExponent() const {

    return exp;

}

const BigInteger& RSAPublicKey::getModulus() const {

    return mod;

}
