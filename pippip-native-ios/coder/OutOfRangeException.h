#ifndef OUTOFRANGEEXCEPTION_H_INCLUDED
#define OUTOFRANGEEXCEPTION_H_INCLUDED

#include "Exception.h"
#include <string>

namespace coder {

class OutOfRangeException : public Exception {

    protected:
        OutOfRangeException() {}

    public:
        OutOfRangeException(const std::string& msg) : Exception(msg) {}
        OutOfRangeException(const OutOfRangeException& other)
                : Exception(other) {}
#ifdef __MACH__
        ~OutOfRangeException() _NOEXCEPT {}
#else
        ~OutOfRangeException() {}
#endif

    private:
        OutOfRangeException& operator= (const OutOfRangeException& other);

};

}

#endif // OUTOFRANGEEXCEPTION_H_INCLUDED
