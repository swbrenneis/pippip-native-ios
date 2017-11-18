#include "PSSmgf1.h"
#include "Digest.h"
#include "ByteArray.h"
#include "Unsigned32.h"
#include "BadParameterException.h"
#include <cmath>

PSSmgf1::PSSmgf1(Digest *digest)
: hash(digest) {
}

PSSmgf1::~PSSmgf1() {
}

/*
* Generate the mask.
*/
coder::ByteArray PSSmgf1::generateMask(const coder::ByteArray& mgfSeed, size_t maskLen) {

    hash->reset();
    int hLen = hash->getDigestLength();
    if (maskLen > 0x100000000L * hLen) {
        throw new BadParameterException("Mask length out of bounds");
    }

    coder::ByteArray T;
    double doubleMaskLen = maskLen;
    for (int counter = 0; counter < std::ceil(doubleMaskLen / hLen);
                                                            ++counter) {
        coder::ByteArray C(coder::Unsigned32(counter).getEncoded(coder::bigendian));
        coder::ByteArray h;
        h.append(mgfSeed);
        h.append(C);
        coder::ByteArray t(hash->digest(h));

        T.append(t);
    }

    return T.range(0, maskLen);

}
