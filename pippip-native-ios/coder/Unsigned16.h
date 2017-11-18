#ifndef UNSIGNED16_H_INCLUDED
#define UNSIGNED16_H_INCLUDED

#include "Constants.h"
#include "ByteArray.h"

namespace coder {

class Unsigned16 {

    public:
        Unsigned16();
        Unsigned16(uint16_t v);
        //Unsigned16(const ByteArray& encoded);
        Unsigned16(const ByteArray& encoded, Endian endian = bigendian);
        Unsigned16(const Unsigned16& other);

        ~Unsigned16();

    public:
        Unsigned16& operator= (const Unsigned16& other);

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
        uint16_t getValue() const;
        // Sets the unsigned value.
        void setValue(uint16_t v);
        // Output the value as a hexadecimal string.
        std::string toHexString(Endian e, bool prefix = false);

    private:
        //void endianTest();
        void encode(Endian eType);

    private:
        uint16_t value;
        ByteArray encoded;
        static Endian endian;

};

}

#endif  // UNSIGNED16_H_INCLUDED
