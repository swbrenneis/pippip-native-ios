#ifndef BYTEARRAY_H_INCLUDED
#define BYTEARRAY_H_INCLUDED

#include <deque>
#include <string>
#include <ostream>
#include <cstdint>

namespace coder {

/*
 * This really just encapsulates a deque, but it provides
 * some convenience methods and extra management
 */
class ByteArray {

    private:
        typedef std::deque<uint8_t> Array;

    public:
        ByteArray();
        ByteArray(const ByteArray& other);
        // Construct a ByteArray from anther ByteArray's range
        ByteArray(const ByteArray& other, unsigned long offset, unsigned long length);
        // Construct a ByteArray from an array of uint8_t
        ByteArray(const uint8_t *bytes, unsigned long length);
        // Construct a ByteArray from a standard string.
        explicit ByteArray(const std::string& str, bool hex = false);
        // Construct a ByteArray with an initial size
        explicit ByteArray(unsigned long size, uint8_t fill=0);
        ~ByteArray();

    private:
        ByteArray(const Array& byteArray);

    public:
        ByteArray& operator= (const ByteArray& other);
        ByteArray& operator= (const std::string& str);
        uint8_t& operator[] (unsigned long index);
        uint8_t operator[] (unsigned long index) const;

    public:
        void append(const ByteArray& other);
        void append(const ByteArray& other, unsigned long offset, unsigned long length);
        void append(const uint8_t *byte, unsigned long length);
        void append(const std::string& str);
        void append(uint8_t c);
        // Returns an array of bytes. Caller owns the pointer.
        uint8_t *asArray() const;
        std::string asHex(unsigned long index) const;
        void clear();
        void copy(unsigned long offset, const ByteArray& other,
                        unsigned long otherOffset, unsigned long length=0);
        void copy(unsigned long offset, const uint8_t *other,
                        unsigned long otherOffset, unsigned long length=0);
        bool equals(const ByteArray& other) const;
        // Reverses the order of the array.
        void flip();
        unsigned long length() const;
        void push(const ByteArray& b);
        void push(uint8_t b);
        // Get a subrange of the array. If length is zero get the
        // subrange beginning at offset through the end of the array.
        ByteArray range(unsigned long offset, unsigned long length = 0) const;
        void setLength(unsigned long newLength, uint8_t fill = 0);
        std::string toHexString() const;
        std::string toLiteralString() const;
        void truncate(unsigned long size);

    private:
        Array bytes;
        typedef Array::const_iterator ArrayConstIter;
        typedef Array::iterator ArrayIter;

};

}

// Global operators
bool operator== (const coder::ByteArray& lhs, const coder::ByteArray& rhs);
bool operator!= (const coder::ByteArray& lhs, const coder::ByteArray& rhs);
coder::ByteArray operator^ (const coder::ByteArray& lhs, const coder::ByteArray& rhs);
coder::ByteArray operator <<(const coder::ByteArray& lhs, int shiftbits);
coder::ByteArray operator >>(const coder::ByteArray& lhs, int shiftbits);
std::ostream& operator <<(std::ostream& out, const coder::ByteArray& bytes);
std::ostream& operator >>(std::ostream& in, const coder::ByteArray& bytes);

#endif // BYTEARRAY_H_INCLUDED
