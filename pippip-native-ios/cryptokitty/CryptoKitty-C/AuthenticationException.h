#ifndef AUTHENTICATIONEXCEPTION_H_INCLUDED
#define AUTHENTICATIONEXCEPTION_H_INCLUDED

#include "CKException.h"

class AuthenticationException : public CKException {

    protected:
        AuthenticationException() {}

    public:
        AuthenticationException(const std::string& msg) : CKException(msg) {}
        AuthenticationException(const CKException& other)
                : CKException(other) {}

    private:
        AuthenticationException& operator= (const AuthenticationException& other);

    public:
        ~AuthenticationException() {}

};

#endif // AUTHENTICATIONEXCEPTION_H_INCLUDED
