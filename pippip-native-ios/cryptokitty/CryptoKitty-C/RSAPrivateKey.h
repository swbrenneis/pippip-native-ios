#ifndef RSAPRIVATEKEY_H_INCLUDED
#define RSAPRIVATEKEY_H_INCLUDED

#include "PrivateKey.h"
#include "BigInteger.h"

class RSAPrivateKey : public PrivateKey {

    public:
        enum KeyType { crt, mod };

    private:
        RSAPrivateKey();

    protected:
        RSAPrivateKey(KeyType keyType);

    public:
        virtual ~RSAPrivateKey();

    private:
        RSAPrivateKey(const RSAPrivateKey& other);
        RSAPrivateKey& operator=(const RSAPrivateKey& other);

    public:
        virtual size_t getBitLength() const { return bitLength; }
        virtual KeyType getKeyType() const { return keyType; }

    protected:
        friend class PKCS1rsassa;
        friend class PSSrsassa;
        friend class OAEPrsaes;
        // Decryption primitive.
        virtual BigInteger rsadp(const BigInteger& c) const=0;
        // Signature generation primitive.
        virtual BigInteger rsasp1(const BigInteger& m) const=0;

    protected:
        size_t bitLength;

    private:
        KeyType keyType;

};

#endif  // RSAPRIVATEKEY_H_INCLUDED
