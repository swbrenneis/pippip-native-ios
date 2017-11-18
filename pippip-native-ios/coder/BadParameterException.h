#ifndef BADPARAMETEREXCEPTION_H_INCLUDED
#define BADPARAMETEREXCEPTION_H_INCLUDED

#include "Exception.h"
#include <string>

namespace coder {

class BadParameterException : public Exception {

    protected:
        BadParameterException() {}

    public:
        BadParameterException(const std::string& msg) : Exception(msg) {}
        BadParameterException(const BadParameterException& other)
                : Exception(other) {}
#ifdef __MACH__
        ~BadParameterException() _NOEXCEPT {}
#else
        ~BadParameterException() {}
#endif

    private:
        BadParameterException& operator= (const BadParameterException& other);

};

}

#endif // BADPARAMETEREXCEPTION_H_INCLUDED
