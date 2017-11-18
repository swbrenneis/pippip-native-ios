#ifndef BYTEARRAYINPUTSTREAM_H_INCLUDED
#define BYTEARRAYINPUTSTREAM_H_INCLUDED

#include "ByteArray.h"

namespace coder {

class ByteArrayInputStream {

    public:
        ByteArrayInputStream(const ByteArray& theArray);
        ~ByteArrayInputStream();

    private:
        ByteArrayInputStream(const ByteArrayInputStream& other);
        ByteArrayInputStream& operator= (const ByteArrayInputStream& other);

    public:
        unsigned long available() const;
        bool eof() const;
        uint8_t read();
        void read(ByteArray& bytes);
        void read(ByteArray& bytes, unsigned long offset, unsigned long length);
        void reset();

    private:
        unsigned pos;
        ByteArray theArray;

};

}

#endif // BYTEARRAYINPUTSTREAM_H_INCLUDED

