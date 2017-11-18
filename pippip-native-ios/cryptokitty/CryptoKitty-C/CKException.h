#ifndef CKEXCEPTION_H_INCLUDED
#define CKEXCEPTION_H_INCLUDED

#include <exception>
#include <string>

#ifdef __MACH__
#define EXCEPTION_THROW_SPEC throw()
#else
#define EXCEPTION_THROW_SPEC noexcept
#endif

class CKException  : public std::exception {

    protected:
        CKException() {}
        CKException(const std::string& msg) : message(msg) {}
        CKException(const CKException& other)
                : message(other.message) {}

    private:
        CKException& operator= (const CKException& other);

    public:
        ~CKException() {}

    public:
        const char *what() const EXCEPTION_THROW_SPEC { return message.c_str(); }

    private:
        std::string message;

};

#endif // CKEXCEPTION_H_INCLUDED
