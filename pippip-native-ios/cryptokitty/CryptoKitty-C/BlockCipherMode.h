#ifndef BLOCKCIPHERMODE_H_INCLUDED
#define BLOCKCIPHERMODE_H_INCLUDED

namespace coder {
    class ByteArray;
}

class BlockCipherMode {

    protected:
        BlockCipherMode() {}
        
    public:
        virtual ~BlockCipherMode() {}

    private:
        BlockCipherMode(const BlockCipherMode& other);
        BlockCipherMode& operator= (const BlockCipherMode& other);

    public:
        virtual coder::ByteArray decrypt(const coder::ByteArray& ciphertext,
                                            const coder::ByteArray& key)=0;
        virtual coder::ByteArray encrypt(const coder::ByteArray& plaintext,
                                            const coder::ByteArray& key)=0;
        virtual void setIV(const coder::ByteArray& iv)=0;

};

#endif  // BLOCKCIPHERMODE_H_INCLUDED
