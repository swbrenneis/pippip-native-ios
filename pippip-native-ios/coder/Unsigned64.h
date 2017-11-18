#ifndef UNSIGNED64_H_INCLUDED
#define UNSIGNED64_H_INCLUDED

#include "Constants.h"
#include "ByteArray.h"

namespace coder {

class Unsigned64 {

    public:
        Unsigned64();
        Unsigned64(uint64_t v);
        //Unsigned64(const ByteArray& encoded);
        Unsigned64(const ByteArray& encoded, Endian endian = bigendian);
        Unsigned64(const Unsigned64& other);

        ~Unsigned64();

    public:
        Unsigned64& operator= (const Unsigned64& other);

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
        uint64_t getValue() const;
        // Sets the unsigned value.
        void setValue(uint64_t v);
        // Output the value as a hexadecimal string.
        std::string toHexString(Endian e, bool prefix = false);

    private:
        //void endianTest();
        void encode(Endian eType);

    private:
        uint64_t value;
        ByteArray encoded;
        static Endian endian;

};

}

#endif  // UNSIGNED64_H_INCLUDED
