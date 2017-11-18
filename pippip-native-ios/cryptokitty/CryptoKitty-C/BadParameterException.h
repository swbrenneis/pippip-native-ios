#ifndef BADPARAMETEREXCEPTION_H_INCLUDED
#define BADPARAMETEREXCEPTION_H_INCLUDED

#include "CKException.h"

class BadParameterException : public CKException {

    protected:
        BadParameterException() {}

    public:
        BadParameterException(const std::string& msg) : CKException(msg) {}
        BadParameterException(const BadParameterException& other)
                : CKException(other) {}

    private:
        BadParameterException& operator= (const BadParameterException& other);

    public:
        ~BadParameterException() {}

};

#endif // BADPARAMETEREXCEPTION_H_INCLUDED
