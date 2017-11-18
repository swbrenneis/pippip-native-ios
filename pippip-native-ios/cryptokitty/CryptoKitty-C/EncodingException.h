#ifndef ENCODINGEXCEPTION_H_INCLUDED
#define ENCODINGEXCEPTION_H_INCLUDED

#include "CKException.h"

class EncodingException : public CKException {

    protected:
        EncodingException() {}

    public:
        EncodingException(const std::string& msg) : CKException(msg) {}
        EncodingException(const CKException& other)
                : CKException(other) {}

    private:
        EncodingException& operator= (const EncodingException& other);

    public:
        ~EncodingException() {}

};

#endif // ENCODINGEXCEPTION_H_INCLUDED
