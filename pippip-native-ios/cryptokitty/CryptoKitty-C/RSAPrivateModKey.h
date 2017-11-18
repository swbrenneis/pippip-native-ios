#ifndef RSAPRIVATEMODKEY_H_INCLUDED
#define RSAPRIVATEMODKEY_H_INCLUDED

#include "RSAPrivateKey.h"
#include "BigInteger.h"

class RSAPrivateModKey : public RSAPrivateKey {

    private:
        RSAPrivateModKey();
        RSAPrivateModKey(const RSAPrivateModKey& other);
        RSAPrivateModKey& operator= (const RSAPrivateModKey& other);

    public:
        RSAPrivateModKey(const BigInteger& d, const BigInteger& n);
        ~RSAPrivateModKey();

    public:
        const BigInteger& getPrivateExponent() const { return prvExp; }
        const BigInteger& getModulus() const { return mod; }

    protected:
        // Decryption primitive.
        BigInteger rsadp(const BigInteger& c) const;
        // Signature generation primitive.
        BigInteger rsasp1(const BigInteger& m) const;

    private:
        BigInteger prvExp;  // d
        BigInteger mod; // n

};

#endif  // RSAPRIVATEMODKEY_H_INCLUDED
