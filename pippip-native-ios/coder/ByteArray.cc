#include "ByteArray.h"
#include "OutOfRangeException.h"
#include "BadParameterException.h"
#include <memory>

namespace coder {

ByteArray::ByteArray() {
}

ByteArray::ByteArray(const ByteArray& other)
: bytes(other.bytes) {
}

/*
 * Construct a ByteArray object from another ByteArray's range.
 */
ByteArray::ByteArray(const ByteArray& other, unsigned long offset, unsigned long length) {

    if (offset + length > other.length()) {
        throw OutOfRangeException("Array parameters out of range");
    }

    bytes.assign(other.bytes.begin()+offset, other.bytes.begin()+offset+length);

}

/*
 * Construct a ByteArray object from a C array.
 */
ByteArray::ByteArray(const uint8_t *bytearray, unsigned long length)
: bytes(bytearray, bytearray+length) {
}

/*
 * Construct a ByteArray object from a standard string. If the hex flag
 * is true, the string is treated as a representation of a string of
 * hexadecimal bytes.
 */
ByteArray::ByteArray(const std::string& str, bool hex) {

    if (hex) {
        std::string work = str;
        if (str.length() % 2 != 0) {    // Odd number of characters, prefix a '0'.
            work = std::string("0") + work;
        }
        bool hi = true;
        uint8_t byte = 0;
        for (unsigned i = 0; i < work.length(); ++i) {
            char c = work[i];
            uint8_t nib;
            if (c >= 'a' && c <= 'f') {
                nib = (c - 'a') + 10;
            }
            else if (c >= '0' && c <= '9') {
                nib = c - '0';
            }
            else {
                throw BadParameterException("Invalid hex string");
            }
            if (hi) {
                hi = false;
                byte = nib << 4;
            }
            else {
                byte |= nib;
                bytes.push_back(byte);
                hi = true;
            }
        }
    }
    else {
        bytes.assign(str.begin(), str.end());
    }

}

/*
 * Construct a ByteArray of a specified size. The content is
 * undefined.
 */
ByteArray::ByteArray(unsigned long size, uint8_t fill) {

    bytes.assign(size, fill);

}

/*
 * Cconstruct a ByteArray object from an Array object.
 */
ByteArray::ByteArray(const Array& array)
: bytes(array) {
}

ByteArray::~ByteArray() {
}

ByteArray& ByteArray::operator= (const ByteArray& other) {

    bytes = other.bytes;
    return *this;

}

ByteArray& ByteArray::operator= (const std::string& str) {

    bytes.assign(str.begin(), str.end());
    return *this;

}

uint8_t& ByteArray::operator[] (unsigned long index) {

    if (index >= bytes.size()) {
         throw OutOfRangeException("ByteArray index out of bounds");
    }

    return bytes[index];

}

uint8_t ByteArray::operator[] (unsigned long index) const {

    if (index >= bytes.size()) {
         throw OutOfRangeException("ByteArray index out of bounds");
    }

    return bytes[index];

}

void ByteArray::append(const ByteArray& other) {

    bytes.insert(bytes.end(), other.bytes.begin(), other.bytes.end());

}

void ByteArray::append(const ByteArray& other, unsigned long offset, unsigned long length) {

    if (offset + length > other.length()) {
        throw OutOfRangeException("Array parameters out of range");
    }
    append(other.range(offset, length));

}

void ByteArray::append(const uint8_t *byte, unsigned long length) {

    Array appendix(byte, byte+length);
    bytes.insert(bytes.end(), appendix.begin(), appendix.end());

}

void ByteArray::append(uint8_t c) {

    bytes.push_back(c);

}

void ByteArray::append(const std::string& str) {

    bytes.insert(bytes.end(), str.begin(), str.end());

}

uint8_t *ByteArray::asArray() const {

    uint8_t *result = new uint8_t[bytes.size()];
    uint8_t *resultptr = result;
    ArrayConstIter it = bytes.begin();
    while (it != bytes.end()) {
        *resultptr = *it;
        resultptr++;
        it++;
    }
    return result;

}

std::string ByteArray::asHex(unsigned long index) const {

    if (index >= bytes.size()) {
        throw OutOfRangeException("Index out of range");
    }

    std::string result("0x");

    uint8_t u = bytes[index] >> 4;
    if (u < 0x0a) {
        result += (u + '0');
    }
    else {
        result += ((u - 0x0a) + 'a');
    }

    uint8_t l = bytes[index] & 0x0f;
    if (l < 0x0a) {
        result += (l + '0');
    }
    else {
        result += ((l - 0x0a) + 'a');
    }

    return result;

}

void ByteArray::clear() {

    bytes.clear();

}

/*
 * Copy a subrange of this another array array to this one. Existing
 * elements within the copy range are overwritten. The array size
 * is adjusted accordingly. OutOfRangeException if the other array
 * size is violated. If length is zero, the copy size is calculated from
 * the size of the other array.
 */
void ByteArray::copy(unsigned long offset, const ByteArray& other,
                        unsigned long otherOffset, unsigned long length) {

    unsigned long transfer = length;
    if (length == 0) {
        transfer = other.length() - otherOffset;
    }
    if ((otherOffset + transfer) > other.length()) {
        throw OutOfRangeException("Copy parameters out of range");
    }
    if (offset + transfer > bytes.size()) {
        bytes.resize(transfer - offset);
    }
    ArrayConstIter otherIt = other.bytes.begin();
    otherIt += otherOffset;
    ArrayIter it = bytes.begin();
    it += offset;
    unsigned transferred = 0;
    while (transferred++ < transfer) {
        *it++ = *otherIt++;
    }

}

/*
 * Convenience copy method.
 */
void ByteArray::copy(unsigned long offset, const uint8_t *other,
                        unsigned long otherOffset, unsigned long length) {

    copy(offset, ByteArray(other+otherOffset, length), 0, length);

}

bool ByteArray::equals(const ByteArray& other) const {

    return bytes == other.bytes;

}

/*
 * Reverse the order of the buffer.
 */
void ByteArray::flip() {

    std::deque<uint8_t> temp;

    while (bytes.size() > 0) {
        temp.push_front(bytes.front());
        bytes.pop_front();
    }

    bytes.swap(temp);

}

unsigned long ByteArray::length() const {

    return bytes.size();

}

/*
 * Push a byte onto the front of the array.
 */
void ByteArray::push(uint8_t b) {

    bytes.push_front(b);

}

/*
 * Return a subrange of this array. If length is zero, return the rest
 * of the array beginning at index.
 */
ByteArray ByteArray::range(unsigned long offset, unsigned long length) const {

    if (offset + length > bytes.size()) {
        throw OutOfRangeException("Array parameters out of range");
    }

    unsigned long toCopy = length;
    if (length == 0) {
        toCopy = bytes.size() - offset;
    }

    ArrayConstIter it = bytes.begin() + offset;
    Array result(it, it+toCopy);
    return result;

}

void ByteArray::setLength(unsigned long newLength, uint8_t fill) {

    bytes.resize(newLength, fill);

}

std::string ByteArray::toHexString() const {

    std::string result;
    for (ArrayConstIter it = bytes.begin(); it != bytes.end(); ++it) {
        char nybble = (*it & 0xf0) >> 4;
        if (nybble < 0x0a) {
            result += nybble + '0';
        }
        else {
            result += (nybble - 0x0a) + 'a';
        }
        nybble = *it & 0x0f;
        if (nybble < 0x0a) {
            result += nybble + '0';
        }
        else {
            result += (nybble - 0x0a) + 'a';
        }
    }
    return result;;
    
}

std::string ByteArray::toLiteralString() const {

    std::unique_ptr<uint8_t[]> ubuf(asArray());
    char *cbuf = reinterpret_cast<char*>(ubuf.get());

    std::string lit(cbuf, bytes.size());

    return lit;

}

void ByteArray::truncate(unsigned long size) {

    if (size >= bytes.size()) {
        bytes.clear();
    }
    else {
        bytes.resize(bytes.size() - size);
    }

}

}

// Global operators.
bool operator== (const coder::ByteArray& lhs, const coder::ByteArray& rhs)
{ return lhs.equals(rhs); }
bool operator!= (const coder::ByteArray& lhs, const coder::ByteArray& rhs)
{ return !lhs.equals(rhs); }
std::ostream& operator <<(std::ostream& out, const coder::ByteArray& bytes) {

    int column = 1;
    for (unsigned n = 0; n < bytes.length(); ++n) {
        out << bytes.asHex(n);
        if (column < 16) {
            out << ", ";
        }
        else {
            out << std::endl;
            column = 0;
        }
        column++;
    }

    return out;

}

coder::ByteArray operator^ (const coder::ByteArray& lhs, const coder::ByteArray& rhs) {

    if (lhs.length() != rhs.length()) {
        throw coder::BadParameterException("XOR operator: Array sizes not equal.");
    }

    coder::ByteArray result(lhs.length());
    for (unsigned long n = 0; n < lhs.length(); ++n) {
        result[n] = lhs[n] ^ rhs[n];
    }

    return result;

}

coder::ByteArray operator<< (const coder::ByteArray& lhs, int shiftbits) {

    coder::ByteArray result(lhs);
    for (int i = 0; i < shiftbits; ++i) {
        for (long n = result.length() - 1; n >= 0; --n) {
            uint8_t carry = 0;
            if (n > 0 && (result[n-1] & 0x80) != 0) {
                carry = 1;
            }
            result[n] = (result[n] << 1) | carry;
        }
    }

    return result;

}

coder::ByteArray operator>> (const coder::ByteArray& lhs, int shiftbits) {

    coder::ByteArray result(lhs);
    for (int i = 0; i < shiftbits; ++i) {
        for (unsigned n = 0; n < result.length(); ++n) {
            uint8_t carry = 0;
            if (n < (result.length() - 1)
                            && (result[n+1] & 0x01) != 0) {
                carry = 0x80;
            }
            result[n] = (result[n] >> 1) | carry;
        }
    }

    return result;

}

