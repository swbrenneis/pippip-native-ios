#ifndef PSSMGF1_H_INCLUDED
#define PSSMGF1_H_INCLUDED

#include <cstdlib>

namespace coder {
    class ByteArray;
}

class Digest;

/*
 * Mask generation function. See RFC 3447, Appendix B.2.1 for details
 */
class PSSmgf1 {
                        
    public:
        PSSmgf1(Digest *digest);
        ~PSSmgf1();

    private:
        PSSmgf1(const PSSmgf1& other);
        PSSmgf1& operator= (const PSSmgf1& other);

    public:
        coder::ByteArray generateMask(const coder::ByteArray& mgfSeed, size_t maskLen);

    private:
        // This class does not own this pointer.
        Digest *hash;

};

#endif  // PSSMGF1_H_INCLUDED
