#ifndef RSAKEYPAIRGENERATOR_H_INCLUDED
#define RSAKEYPAIRGENERATOR_H_INCLUDED

#include "BigInteger.h"
#include "KeyPair.h"
#include "RSAPublicKey.h"
#include "RSAPrivateKey.h"

class SecureRandom;

typedef KeyPair<RSAPublicKey, RSAPrivateKey> RSAKeyPair;

class RSAKeyPairGenerator {

    public:
        RSAKeyPairGenerator();
        ~RSAKeyPairGenerator();

    private:
        RSAKeyPairGenerator(const RSAKeyPairGenerator& other);
        RSAKeyPairGenerator&
                operator= (const RSAKeyPairGenerator& other);

    public:
        RSAKeyPair *generateKeyPair(bool crt = true);
        void initialize(int bits, SecureRandom* secure);

    private:
        int keySize;
        SecureRandom *random;

        static const BigInteger THREE;

};

#endif	// RSAKEYPAIRGENERATOR_H_INCLUDED
