#ifndef INT16_H_INCLUDED
#define INT16_H_INCLUDED

#include "ByteArray.h"
#include "Constants.h"

namespace coder {

class Int16 {

    public:
        Int16();
        Int16(int16_t v);
        //Int16(const ByteArray& encoded);
        Int16(const ByteArray& encoded, Endian endian = bigendian);
        Int16(const Int16& other);

        ~Int16();

    public:
        Int16& operator= (const Int16& other);

    public:
        // Decode a byte array in the native endian order.
        //void decode(const ByteArray& encoded);
        // Decode a byte array in the specified endian order.
        void decode(const ByteArray& encoded, Endian endian = bigendian);
        // Returns an encoded array in the native endian order.
        //const ByteArray& getEncoded();
        // Returns an encoded array in the specified endian order.
        const ByteArray& getEncoded(Endian endian = bigendian);
        // Returns a signed integer.
        int16_t getValue() const;
        // Set the integer value.
        void setValue(int16_t v);

    private:
        //void endianTest();
        void encode(Endian eType);

    private:
        int16_t value;
        ByteArray encoded;
        static Endian endian;

};

}

#endif  // INT16_H_INCLUDED
