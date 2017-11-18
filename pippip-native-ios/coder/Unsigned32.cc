#include "Unsigned32.h"
#include "OutOfRangeException.h"
#include "BadParameterException.h"
#include <cmath>

namespace coder {

// Static initializations
Endian Unsigned32::endian = none;

Unsigned32::Unsigned32() 
: value(0) {

    //endianTest();
}

Unsigned32::Unsigned32(uint32_t v) 
: value(v) {

    //endianTest();

}
/*
Unsigned32::Unsigned32(const ByteArray& enc) {

    if (enc.length() < 4) {
        throw OutOfRangeException("Invalid encoding length");
    }

    endianTest();
    decode(enc, endian);

}
*/
Unsigned32::Unsigned32(const ByteArray& enc, Endian eType) {

    if (enc.length() < 4) {
        throw OutOfRangeException("Invalid encoding length");
    }

    //endianTest();
    decode(enc, eType);

}

Unsigned32::Unsigned32(const Unsigned32& other)
: value(other.value) {
}

Unsigned32& Unsigned32::operator= (const Unsigned32& other) {

    value = other.value;
    return *this;

}

Unsigned32::~Unsigned32() {
}

/*
 * Decode the encoded array in the specified endian format.
void Unsigned32::decode(const ByteArray& enc) {

    decode(enc, endian);

}
 */

/*
 * Decode the encoded array in the specified endian format.
 */
void Unsigned32::decode(const ByteArray& enc, Endian eType) {

    if (enc.length() < 4) {
        throw OutOfRangeException("Invalid encoding length");
    }

    value = 0;
    switch (eType) {
        case bigendian:
            for (int n = 0; n < 4; ++n) {
                value = value << 8;
                value |= enc[n];
            }
            break;
        case littleendian:
            for (int n = 3; n >= 0; --n) {
                value = value << 8;
                value |= enc[n];
            }
            break;
        default:
            throw BadParameterException("Illegal endian value");
    }

}

/*
 * Encode the value in the specified endian order.
 */
void Unsigned32::encode(Endian eType) {

    encoded.setLength(4);
    uint32_t tmp = value;
    switch(eType) {
        case littleendian:
            for (int n = 0; n < 4; ++n) {
                encoded[n] = tmp & 0xff;
                tmp = tmp >> 8;
            }
            break;
        case bigendian:
            for (int n = 3; n >= 0; --n) {
                encoded[n] = tmp & 0xff;
                tmp = tmp >> 8;
            }
            break;
        default:
            throw OutOfRangeException("Illegal endian value");
    }

}

/*
 * Endian test.
void Unsigned32::endianTest() {

    if (endian == none) {
        unsigned short test = 0x4578;
        if ((test & 0xff) == 0x45) {
            endian = bigendian;
        }
        else {
            endian = littleendian;
        }
    }

}
 */

/*
 * Returns the value encoded in an 8 byte array in native
 * endian order.
const ByteArray& Unsigned32::getEncoded() {

    return getEncoded(endian);

}
 */

/*
 * Returns the value encoded in an 8 byte array in the
 * specified endian order.
 */
const ByteArray& Unsigned32::getEncoded(Endian eType) {

    encode(eType);
    return encoded;

}

/*
 * Returns an unsigned integer value.
 */
uint32_t Unsigned32::getValue() const {

    return value;

}

/*
 * Set the unsigned value.
 */
void Unsigned32::setValue(uint32_t v) {

    value = v;

}

/*
 * Output the value as a hexadecimal string in the specified endian order.
 */
std::string Unsigned32::toHexString(Endian e, bool prefix) {

    encode(e);

    std::string hex;
    if (prefix) {
        hex = "0x";
    }
    switch (e) {
        case bigendian:
            for (int i = 0; i < 4; ++i) {
                hex += encoded.asHex(i).substr(2,2);
            }
            break;
        case littleendian:
            for (int i = 3; i >= 0; --i) {
                hex += encoded.asHex(i).substr(2,2);
            }
            break;
        default:
            throw BadParameterException("Invalid endian value");
    }

    return hex;

}

}

