#ifndef ILLEGALSTATEEXCEPTION_H_INCLUDED
#define ILLEGALSTATEEXCEPTION_H_INCLUDED

#include "CKException.h"

class IllegalStateException : public CKException {

    protected:
        IllegalStateException() {}

    public:
        IllegalStateException(const std::string& msg) : CKException(msg) {}
        IllegalStateException(const IllegalStateException& other)
                : CKException(other) {}

    private:
        IllegalStateException& operator= (const IllegalStateException& other);

    public:
        ~IllegalStateException() {}

};

#endif // ILLEGALSTATEEXCEPTION_H_INCLUDED
