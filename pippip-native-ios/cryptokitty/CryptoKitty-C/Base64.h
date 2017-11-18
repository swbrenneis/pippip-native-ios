#ifndef BASE64_H_INCLUDED
#define BASE64_H_INCLUDED

#include "ByteArray.h"
#include <iostream>

class Base64 {

    public:
        Base64();
        Base64(const coder::ByteArray& data);
        ~Base64();

    private:
        Base64(const Base64& other);
        Base64& operator= (const Base64& other);

    public:
        void decode(std::istream& in);
        void encode(std::ostream& out);
        const coder::ByteArray& getData() const { return data; }

    private:
        int decodeQuartet(uint8_t *content, char *b64);
        void encodeTriplet(uint8_t *content, int tsize, char *b64);

    private:
        bool pem;
        coder::ByteArray data;

};

#endif // BASE64_H_INCLUDED

