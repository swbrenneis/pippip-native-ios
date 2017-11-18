#include "ByteArrayOutputStream.h"

namespace coder {

ByteArrayOutputStream::ByteArrayOutputStream() {
}

ByteArrayOutputStream::~ByteArrayOutputStream() {
}

void ByteArrayOutputStream::reset() {

    theArray.clear();

}

void ByteArrayOutputStream::write(uint8_t byte) {

    theArray.append(byte);

}

void ByteArrayOutputStream::write(const ByteArray& bytes) {

    theArray.append(bytes);

}

void ByteArrayOutputStream::write(const ByteArray& bytes, unsigned offset, unsigned length) {

    theArray.append(bytes.range(offset, length));

}


}

