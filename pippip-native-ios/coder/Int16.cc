#include "Int16.h"
#include "BadParameterException.h"

namespace coder {

// Static initializations
Endian Int16::endian = none;

Int16::Int16() 
: value(0) {

    //endianTest();
}

Int16::Int16(int16_t v) 
: value(v) {

    //endianTest();

}
/*
Int16::Int16(const ByteArray& enc) {

    if (enc.length() < 2) {
        throw BadParameterException("Invalid encoding length");
    }

    endianTest();
    decode(enc, endian);

}
*/
Int16::Int16(const ByteArray& enc, Endian eType) {

    if (enc.length() < 2) {
        throw BadParameterException("Invalid encoding length");
    }

    //endianTest();
    decode(enc, eType);

}

Int16::Int16(const Int16& other)
: value(other.value) {
}

Int16& Int16::operator= (const Int16& other) {

    value = other.value;
    return *this;

}

Int16::~Int16() {
}

/*
 * Decode the encoded array in the native endian format.
void Int16::decode(const ByteArray& enc) {

    decode(enc, endian);

}
 */

/*
 * Decode the encoded array in the specified endian format.
 */
void Int16::decode(const ByteArray& enc, Endian eType) {

    if (enc.length() < 2) {
        throw BadParameterException("Invalid encoding length");
    }

    uint16_t tmp = 0;
    bool neg = false;
    switch (eType) {
        case bigendian:
            neg = (enc[0] & 0x80) != 0;
            tmp = enc[0];
            tmp = tmp << 8;
            tmp |= enc[1];
            break;
        case littleendian:
            neg = (enc[1] & 0x80) != 0;
            tmp = enc[1];
            tmp = tmp << 8;
            tmp |= enc[0];
            break;
        default:
            throw BadParameterException("Illegal endian value");
    }

    if (neg) {
        value = (tmp ^ 0xffff) + 1;
        value = -value;
    }
    else {
        value = tmp;
    }

}

/*
 * Endian test.
void Int16::endianTest() {

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
 * Encode the value in the specified endian order.
 */
void Int16::encode(Endian eType) {

    encoded.setLength(2);
    uint16_t tmp = std::abs(value);
    if (value < 0) {
        tmp = (tmp ^ 0xffff) + 1;
    }
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
 * Returns the value encoded in an 8 byte array in native
 * endian order.
const ByteArray& Int16::getEncoded() {

    return getEncoded(endian);

}
 */

/*
 * Returns the value encoded in an 8 byte array in the
 * specified endian order.
 */
const ByteArray& Int16::getEncoded(Endian eType) {

    encode(eType);
    return encoded;

}

/*
 * Returns a signed integer value.
 */
int16_t Int16::getValue() const {

    return value;

}

/*
 * Set the integer value.
 */
void Int16::setValue(int16_t v) {

    value = v;

}

}

