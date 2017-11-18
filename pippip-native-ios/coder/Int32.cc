#include "Int32.h"
#include "OutOfRangeException.h"
#include "BadParameterException.h"
#include <cmath>

namespace coder {

// Static initializations
Endian Int32::endian = none;

Int32::Int32() 
: value(0) {

    //endianTest();
}

Int32::Int32(int32_t v) 
: value(v) {

    //endianTest();

}
/*
Int32::Int32(const ByteArray& enc) {

    if (enc.length() < 4) {
        throw OutOfRangeException("Invalid encoding length");
    }

    endianTest();
    decode(enc, endian);

}
*/
Int32::Int32(const ByteArray& enc, Endian eType) {

    if (enc.length() < 4) {
        throw OutOfRangeException("Invalid encoding length");
    }

    //endianTest();
    decode(enc, eType);

}

Int32::Int32(const Int32& other)
: value(other.value) {
}

Int32& Int32::operator= (const Int32& other) {

    value = other.value;
    return *this;

}

Int32::~Int32() {
}

/*
 * Decode the encoded array in the native endian format.
void Int32::decode(const ByteArray& enc) {

    decode(enc, endian);

}
 */

/*
 * Decode the encoded array in the specified endian format.
 */
void Int32::decode(const ByteArray& enc, Endian eType) {

    if (enc.length() < 4) {
        throw OutOfRangeException("Invalid encoding length");
    }

    uint32_t tmp = 0;
    bool neg = false;
    switch (eType) {
        case bigendian:
            neg = (enc[0] & 0x80) != 0;
            for (int n = 0; n < 4; ++n) {
                tmp = tmp << 8;
                tmp |= enc[n];
            }
            break;
        case littleendian:
            neg = (enc[3] & 0x80) != 0;
            for (int n = 3; n >= 0; --n) {
                tmp = tmp << 8;
                tmp |= enc[n];
            }
            break;
        default:
            throw BadParameterException("Illegal endian value");
    }

    if (neg) {
        value = (tmp ^ 0xffffffff) + 1;
        value = -value;
    }
    else {
        value = tmp;
    }

}

/*
 * Encodes value in specified endian order.
 */
void Int32::encode(Endian eType) {

    encoded.setLength(4);
    uint32_t tmp = std::abs(value);
    if (value < 0) {
        tmp = (tmp ^ 0xffffffff) + 1;
    }
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
void Int32::endianTest() {

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
const ByteArray& Int32::getEncoded() {

    return getEncoded(endian);

}
 */

/*
 * Returns the value encoded in an 8 byte array in the
 * specified endian order.
 */
const ByteArray& Int32::getEncoded(Endian eType) {

    encode(eType);
    return encoded;

}

/*
 * Returns a signed integer value.
 */
int32_t Int32::getValue() const {

    return value;

}

/*
 * Sets the integer value.
 */
void Int32::setValue(int32_t v) {

    value = v;

}

}

