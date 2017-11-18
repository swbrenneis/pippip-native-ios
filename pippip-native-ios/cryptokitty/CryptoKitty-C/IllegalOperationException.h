#ifndef ILLEGALOPERATIONEXCEPTION_H_INCLUDED
#define ILLEGALOPERATIONEXCEPTION_H_INCLUDED

#include "CKException.h"

class IllegalOperationException : public CKException {

    protected:
        IllegalOperationException() {}

    public:
        IllegalOperationException(const std::string& msg) : CKException(msg) {}
        IllegalOperationException(const IllegalOperationException& other)
                : CKException(other) {}

    private:
        IllegalOperationException& operator= (const IllegalOperationException& other);

    public:
        ~IllegalOperationException() {}

};

#endif // ILLEGALOPERATIONEXCEPTION_H_INCLUDED
