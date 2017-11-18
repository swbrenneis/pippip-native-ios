#ifndef UNSIGNED32_H_INCLUDED
#define UNSIGNED32_H_INCLUDED

#include "Constants.h"
#include "ByteArray.h"

namespace coder {

class Unsigned32 {

    public:
        Unsigned32();
        Unsigned32(uint32_t v);
        //Unsigned32(const ByteArray& encoded);
        Unsigned32(const ByteArray& encoded, Endian endian = bigendian);
        Unsigned32(const Unsigned32& other);

        ~Unsigned32();

    public:
        Unsigned32& operator= (const Unsigned32& other);

    public:
        // Decode a byte array in the native endian order.
        //void decode(const ByteArray& encoded);
        // Decode a byte array in the specified endian order.
        void decode(const ByteArray& encoded, Endian endian = bigendian);
        // Returns an encoded array in the native endian order.
        //const ByteArray& getEncoded();
        // Returns an encoded array in the specified endian order.
        const ByteArray& getEncoded(Endian endian = bigendian);
        // Returns an unsigned integer.
        uint32_t getValue() const;
        // Sets the unsigned value.
        void setValue(uint32_t v);
        // Output the value as a hexadecimal string.
        std::string toHexString(Endian e, bool prefix = false);

    private:
        //void endianTest();
        void encode(Endian eType);

    private:
        uint32_t value;
        ByteArray encoded;
        static Endian endian;

};

}

#endif  // UNSIGNED32_H_INCLUDED
