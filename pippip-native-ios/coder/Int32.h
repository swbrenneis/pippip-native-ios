#ifndef INT32_H_INCLUDED
#define INT32_H_INCLUDED

#include "ByteArray.h"
#include "Constants.h"

namespace coder {

class Int32 {

    public:
        Int32();
        Int32(int32_t v);
        //Int32(const ByteArray& encoded);
        Int32(const ByteArray& encoded, Endian endian = bigendian);
        Int32(const Int32& other);

        ~Int32();

    public:
        Int32& operator= (const Int32& other);

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
        int32_t getValue() const;
        // Set the integer value.
        void setValue(int32_t v);

    private:
        //void endianTest();
        void encode(Endian eType);

    private:
        int32_t value;
        ByteArray encoded;
        static Endian endian;

};

}

#endif  // INT32_H_INCLUDED
