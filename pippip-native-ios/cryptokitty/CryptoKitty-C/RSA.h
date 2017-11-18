#ifndef RSA_H_INCLUDED
#define RSA_H_INCLUDED

#include "BigInteger.h"

class RSAPublicKey;
class RSAPrivateKey;

class RSA {

    protected:
        RSA();

    public:
        virtual ~RSA();

    private:
        static const BigInteger MASK;

    public:
        virtual coder::ByteArray
                decrypt(const RSAPrivateKey& K, const coder::ByteArray& C)=0;
        virtual coder::ByteArray
                encrypt(const RSAPublicKey& K, const coder::ByteArray& P)=0;
        virtual coder::ByteArray sign(const RSAPrivateKey& K, const coder::ByteArray& M)=0;
        virtual bool
                verify(const RSAPublicKey& K, const coder::ByteArray& M,
                                    const coder::ByteArray& S)=0;

    protected:
        coder::ByteArray i2osp(const BigInteger& X, size_t xLen);
        BigInteger os2ip(const coder::ByteArray& X);
        BigInteger rsaep(const RSAPublicKey& K, const BigInteger& p);
        BigInteger rsavp1(const RSAPublicKey& K, const BigInteger& s); 

};

#endif  // RSA_H_INCLUDED
