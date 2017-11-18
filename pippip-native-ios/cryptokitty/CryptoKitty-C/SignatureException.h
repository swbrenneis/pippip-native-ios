#ifndef SIGNATUREEXCEPTION_H_INCLUDED
#define SIGNATUREEXCEPTION_H_INCLUDED

#include "CKException.h"

class SignatureException : public CKException {

    protected:
        SignatureException() {}

    public:
        SignatureException(const std::string& msg) : CKException(msg) {}
        SignatureException(const SignatureException& other)
                : CKException(other) {}

    private:
        SignatureException& operator= (const SignatureException& other);

    public:
        ~SignatureException() {}

};

#endif // SIGNATUREEXCEPTION_H_INCLUDED
