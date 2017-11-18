#include "Int64.h"
#include "OutOfRangeException.h"
#include "BadParameterException.h"
#include <cmath>

namespace coder {

// Static initializations
Endian Int64::endian = none;

Int64::Int64() 
: value(0) {

    //endianTest();
}

Int64::Int64(int64_t v) 
: value(v) {

    //endianTest();

}
/*
Int64::Int64(const ByteArray& enc) {

    if (enc.getLength() < 8) {
        throw OutOfRangeException("Invalid encoding length");
    }

    endianTest();
    decode(enc, endian);

}
*/
Int64::Int64(const ByteArray& enc, Endian eType) {

    if (enc.length() < 8) {
        throw OutOfRangeException("Invalid encoding length");
    }

    //endianTest();
    decode(enc, eType);

}

Int64::Int64(const Int64& other)
: value(other.value) {
}

Int64& Int64::operator= (const Int64& other) {

    value = other.value;
    return *this;

}

Int64::~Int64() {
}

/*
 * Decode the encoded array in the native endian format.
void Int64::decode(const ByteArray& enc) {

    decode(enc, endian);

}
 */

/*
 * Decode the encoded array in the specified endian format.
 */
void Int64::decode(const ByteArray& enc, Endian eType) {

    if (enc.length() < 8) {
        throw OutOfRangeException("Invalid encoding length");
    }

    uint64_t tmp = 0;
    bool neg = false;
    switch (eType) {
        case bigendian:
            neg = (enc[0] & 0x80) != 0;
            for (int n = 0; n < 8; ++n) {
                tmp = tmp << 8;
                tmp |= enc[n];
            }
            break;
        case littleendian:
            neg = (enc[3] & 0x80) != 0;
            for (int n = 7; n >= 0; --n) {
                tmp = value << 8;
                tmp |= enc[n];
            }
            break;
        default:
            throw BadParameterException("Illegal endian value");
    }

    if (neg) {
        value = (tmp ^ 0xffffffffffffffff) + 1;
        value = -value;
    }
    else {
        value = tmp;
    }

}

/*
 * Encodes value in specified endian order.
 */
void Int64::encode(Endian eType) {

    encoded.setLength(8);
    uint64_t tmp = std::abs(value);
    if (value < 0) {
        tmp = (tmp ^ 0xffffffffffffffff) + 1;
    }
    switch(eType) {
        case littleendian:
            for (int n = 0; n < 8; ++n) {
                encoded[n] = tmp & 0xff;
                tmp = tmp >> 8;
            }
            break;
        case bigendian:
            for (int n = 7; n >= 0; --n) {
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
void Int64::endianTest() {

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
const ByteArray& Int64::getEncoded() {

    return getEncoded(endian);

}
 */

/*
 * Returns the value encoded in an 8 byte array in the
 * specified endian order.
 */
const ByteArray& Int64::getEncoded(Endian eType) {

    encode(eType);
    return encoded;

}

/*
 * Returns a signed integer value.
 */
int64_t Int64::getValue() const {

    return value;

}

/*
 * Sets the integer value.
 */
void Int64::setValue(int64_t v) {

    value = v;

}

}

