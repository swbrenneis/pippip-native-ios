#ifndef DECRYPTIONEXCEPTION_H_INCLUDED
#define DECRYPTIONEXCEPTION_H_INCLUDED

#include "CKException.h"

class DecryptionException : public CKException {

    public:
        // No oracles please.
        DecryptionException() : CKException("Decryption failed") {}
        DecryptionException(const DecryptionException& other)
                : CKException(other) {}

    private:
        DecryptionException& operator= (const DecryptionException& other);

    public:
        ~DecryptionException() {}

};

#endif // DECRYPTIONEXCEPTION_H_INCLUDED
