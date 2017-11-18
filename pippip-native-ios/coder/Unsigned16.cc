#include "Unsigned16.h"
#include "BadParameterException.h"

namespace coder {

// Static initializations
Endian Unsigned16::endian = none;

Unsigned16::Unsigned16() 
: value(0) {

    //endianTest();
}

Unsigned16::Unsigned16(uint16_t v) 
: value(v) {

    //endianTest();

}
/*
Unsigned16::Unsigned16(const ByteArray& enc) {

    if (enc.length() < 2) {
        throw BadParameterException("Invalid encoding length");
    }

    endianTest();
    decode(enc, endian);

}
*/
Unsigned16::Unsigned16(const ByteArray& enc, Endian eType) {

    if (enc.length() < 2) {
        throw BadParameterException("Invalid encoding length");
    }

    //endianTest();
    decode(enc, eType);

}

Unsigned16::Unsigned16(const Unsigned16& other)
: value(other.value) {
}

Unsigned16& Unsigned16::operator= (const Unsigned16& other) {

    value = other.value;
    return *this;

}

Unsigned16::~Unsigned16() {
}

/*
 * Decode the encoded array in the native endian format.
void Unsigned16::decode(const ByteArray& enc) {

    decode(enc, endian);

}
 */

/*
 * Decode the encoded array in the specified endian format.
 */
void Unsigned16::decode(const ByteArray& enc, Endian eType) {

    if (enc.length() < 2) {
        throw BadParameterException("Invalid encoding length");
    }

    value = 0;
    switch (eType) {
        case bigendian:
            value = enc[0];
            value = value << 8;
            value |= enc[1];
            break;
        case littleendian:
            value = enc[1];
            value = value << 8;
            value |= enc[0];
            break;
        default:
            throw BadParameterException("Illegal endian value");
    }

}

/*
 * Encode the value in the specified endian order.
 */
void Unsigned16::encode(Endian eType) {

    encoded.setLength(2);
    long tmp = value;
    switch(eType) {
        case littleendian:
            encoded[0] = tmp & 0xff;
            tmp = tmp >> 8;
            encoded[1] = tmp & 0xff;
            break;
        case bigendian:
            encoded[1] = tmp & 0xff;
            tmp = tmp >> 8;
            encoded[0] = tmp & 0xff;
            break;
        default:
            throw BadParameterException("Illegal endian value");
    }

}

/*
 * Endian test.
void Unsigned16::endianTest() {

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
const ByteArray& Unsigned16::getEncoded() {

    return getEncoded(endian);

}
 */

/*
 * Returns the value encoded in an 8 byte array in the
 * specified endian order.
 */
const ByteArray& Unsigned16::getEncoded(Endian eType) {

    encode(eType);
    return encoded;

}

/*
 * Returns an unsigned integer value.
 */
uint16_t Unsigned16::getValue() const {

    return value;

}

/*
 * Set the unsigned value.
 */
void Unsigned16::setValue(uint16_t v) {

    value = v;

}

/*
 * Output the value as a hexadecimal string in the specified endian order.
 */
std::string Unsigned16::toHexString(Endian e, bool prefix) {

    encode(e);

    std::string hex;
    if (prefix) {
        hex = "0x";
    }
    switch (e) {
        case bigendian:
            hex = encoded.asHex(0).substr(2,2);
            hex += encoded.asHex(1).substr(2,2);
            break;
        case littleendian:
            hex = encoded.asHex(1).substr(2,2);
            hex += encoded.asHex(0).substr(2,2);
            break;
        default:
            throw BadParameterException("Invalid endian value");
    }

    return hex;

}

}

