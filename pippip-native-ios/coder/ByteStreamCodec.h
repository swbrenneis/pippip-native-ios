#ifndef BYTESTREAMCODEC_H_INCLUDED
#define BYTESTREAMCODEC_H_INCLUDED

#include "ByteArray.h"

namespace coder {

class ByteStreamCodec {

    public:
        ByteStreamCodec();
        ByteStreamCodec(const ByteArray& stream);
        ByteStreamCodec(const ByteStreamCodec& other);
        ~ByteStreamCodec();

    public:
        unsigned long available() const;
        void clear() { stream.clear(); }
        void getBytes(ByteArray& bytes) const ;
        unsigned long length() const;
        void putBytes(const ByteArray& bytes);
        void reset() { pos = 0; }
        const ByteArray& toArray() const { return stream; }

    protected:
        ByteArray stream;
        mutable unsigned pos;

};

}

coder::ByteStreamCodec& operator << (coder::ByteStreamCodec& out, uint8_t abyte);
coder::ByteStreamCodec& operator >> (coder::ByteStreamCodec& in, uint8_t& abyte);
coder::ByteStreamCodec& operator << (coder::ByteStreamCodec& out, uint16_t ashort);
coder::ByteStreamCodec& operator >> (coder::ByteStreamCodec& in, uint16_t& ashort);
coder::ByteStreamCodec& operator << (coder::ByteStreamCodec& out, int32_t anint);
coder::ByteStreamCodec& operator >> (coder::ByteStreamCodec& in, int32_t& anint);
coder::ByteStreamCodec& operator << (coder::ByteStreamCodec& out, uint32_t anint);
coder::ByteStreamCodec& operator >> (coder::ByteStreamCodec& in, uint32_t& anint);
coder::ByteStreamCodec& operator << (coder::ByteStreamCodec& out, int64_t along);
coder::ByteStreamCodec& operator >> (coder::ByteStreamCodec& in, int64_t& along);
coder::ByteStreamCodec& operator << (coder::ByteStreamCodec& out, uint64_t along);
coder::ByteStreamCodec& operator >> (coder::ByteStreamCodec& in, uint64_t& along);
coder::ByteStreamCodec& operator << (coder::ByteStreamCodec& out, const coder::ByteArray& bytes);
coder::ByteStreamCodec& operator >> (coder::ByteStreamCodec& in, coder::ByteArray& bytes);
coder::ByteStreamCodec& operator << (coder::ByteStreamCodec& out, const std::string& str);
coder::ByteStreamCodec& operator >> (coder::ByteStreamCodec& in, std::string& str);

#endif  // BYTESTREAMCODEC_H_INCLUDED
