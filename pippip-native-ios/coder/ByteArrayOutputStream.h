#ifndef BYTEARRAYOUTPUTSTREAM_H_INCLUDED
#define BYTEARRAYOUTPUTSTREAM_H_INCLUDED

#include "ByteArray.h"

namespace coder {

class ByteArrayOutputStream {

    public:
        ByteArrayOutputStream();
        ~ByteArrayOutputStream();

    private:
        ByteArrayOutputStream(const ByteArrayOutputStream& other);
        ByteArrayOutputStream& operator= (const ByteArrayOutputStream& other);

    public:
        void reset();
        void write(uint8_t byte);
        void write(const ByteArray& bytes);
        void write(const ByteArray& bytes, unsigned offset, unsigned length);
        const ByteArray& toByteArray() const { return theArray; }

    private:
        ByteArray theArray;

};

}

#endif // BYTEARRAYOUTPUTSTREAM_H_INCLUDED

