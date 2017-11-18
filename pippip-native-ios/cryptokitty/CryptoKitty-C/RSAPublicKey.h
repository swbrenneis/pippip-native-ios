#ifndef RSAPUBLICKEY_H_INCLUDED
#define RSAPUBLICKEY_H_INCLUDED

#include "PublicKey.h"
#include "BigInteger.h"

class RSAPublicKey : public PublicKey {

    private:
        RSAPublicKey();
        RSAPublicKey(const RSAPublicKey& other);
        RSAPublicKey& operator= (const RSAPublicKey& other);

    public:
        RSAPublicKey(const BigInteger& n, const BigInteger& e);
        ~RSAPublicKey();

    public:
        size_t getBitLength() const;
        const BigInteger& getPublicExponent() const;
        const BigInteger& getModulus() const;

    private:
        BigInteger exp; // e
        BigInteger mod; // n
        size_t bitLength;

};

#endif  // RSAPUBLICKEY_H_INCLUDED
