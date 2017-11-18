#ifndef BLOCKCIPHER_H_INCLUDED
#define BLOCKCIPHER_H_INCLUDED

namespace coder {
    class ByteArray;
}

class BlockCipher {

    protected:
        BlockCipher() {}

    public:
        virtual ~BlockCipher() {}

    private:
        BlockCipher(const BlockCipher& other);
        BlockCipher& operator= (const BlockCipher& other);

    public:
        virtual unsigned blockSize() const=0;
        virtual coder::ByteArray
                encrypt(const coder::ByteArray& plaintext, const coder::ByteArray& key)=0;
        virtual coder::ByteArray
                decrypt(const coder::ByteArray& ciphertext, const coder::ByteArray& key)=0;
        virtual void reset() = 0;

};

#endif  // BLOCKCIPHER_H_INCLUDED
