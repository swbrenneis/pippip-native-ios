#include "ByteArrayInputStream.h"
#include "OutOfRangeException.h"

namespace coder {

ByteArrayInputStream::ByteArrayInputStream(const ByteArray& bytes)
: pos(0),
  theArray(bytes) {
}

ByteArrayInputStream::~ByteArrayInputStream() {
}

unsigned long ByteArrayInputStream::available() const {

    return theArray.length() - pos;

}

bool ByteArrayInputStream::eof() const {

    return pos == theArray.length();

}

uint8_t ByteArrayInputStream::read() {

    if (pos < theArray.length()) {
        return theArray[pos++];
    }
    else {
        throw OutOfRangeException("End of stream exceeded");
    }

}

void ByteArrayInputStream::read(ByteArray& bytes) {

    read(bytes, 0, bytes.length());

}

void ByteArrayInputStream::read(ByteArray& bytes, unsigned long offset, unsigned long length) {

    if (length <= theArray.length() - pos) {
        bytes.copy(offset, theArray, pos, length);
        pos += length;
    }
    else {
        throw OutOfRangeException("End of stream exceeded");
    }

}

void ByteArrayInputStream::reset() {

    pos = 0;

}


}

