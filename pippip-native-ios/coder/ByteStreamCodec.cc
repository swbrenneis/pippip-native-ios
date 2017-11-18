#include "ByteStreamCodec.h"
#include "Unsigned16.h"
#include "Int32.h"
#include "Unsigned32.h"
#include "Int64.h"
#include "Unsigned64.h"

namespace coder {

ByteStreamCodec::ByteStreamCodec()
: pos(0) {
}

ByteStreamCodec::ByteStreamCodec(const ByteArray& str)
: stream(str),
  pos(0) {
}

ByteStreamCodec::ByteStreamCodec(const ByteStreamCodec& other)
: stream(other.stream),
  pos(other.pos) {
}

ByteStreamCodec::~ByteStreamCodec() {
}

unsigned long ByteStreamCodec::available() const {

    return stream.length() - pos;

}

void ByteStreamCodec::getBytes(ByteArray& bytes) const {

    unsigned long length = bytes.length();
    bytes.clear();
    bytes.append(stream.range(pos, length));
    pos += length;

}

unsigned long ByteStreamCodec::length() const {

    return stream.length() - pos;

}

void ByteStreamCodec::putBytes(const ByteArray& bytes) {

    stream.append(bytes);

}

}

coder::ByteStreamCodec& operator << (coder::ByteStreamCodec& out, uint8_t abyte) {

    coder::ByteArray a(1, abyte);
    out.putBytes(a);
    return out;

}

coder::ByteStreamCodec& operator >> (coder::ByteStreamCodec& in, uint8_t& abyte) {

    coder::ByteArray a(1);
    in.getBytes(a);
    abyte = a[0];
    return in;

}

coder::ByteStreamCodec& operator << (coder::ByteStreamCodec& out, uint16_t ashort) {

    coder::Unsigned16 u16(ashort);
    out.putBytes(u16.getEncoded());
    return out;

}

coder::ByteStreamCodec& operator >> (coder::ByteStreamCodec& in, uint16_t& ashort) {

    coder::ByteArray bytes16(2);
    in.getBytes(bytes16);
    coder::Unsigned16 u16(bytes16);
    ashort = u16.getValue();
    return in;

}

coder::ByteStreamCodec& operator << (coder::ByteStreamCodec& out, int32_t anint) {


    coder::Int32 i32(anint);
    out.putBytes(i32.getEncoded());
    return out;

}

coder::ByteStreamCodec& operator >> (coder::ByteStreamCodec& in, int32_t& anint) {

    coder::ByteArray bytes32(4);
    in.getBytes(bytes32);
    coder::Int32 i32(bytes32);
    anint = i32.getValue();
    return in;

}

coder::ByteStreamCodec& operator << (coder::ByteStreamCodec& out, uint32_t anint) {


    coder::Unsigned32 u32(anint);
    out.putBytes(u32.getEncoded());
    return out;

}

coder::ByteStreamCodec& operator >> (coder::ByteStreamCodec& in, uint32_t& anint) {

    coder::ByteArray bytes32(4);
    in.getBytes(bytes32);
    coder::Unsigned32 u32(bytes32);
    anint = u32.getValue();
    return in;

}

coder::ByteStreamCodec& operator << (coder::ByteStreamCodec& out, int64_t along) {


    coder::Int64 i64(along);
    out.putBytes(i64.getEncoded());
    return out;

}

coder::ByteStreamCodec& operator >> (coder::ByteStreamCodec& in, int64_t& along) {

    coder::ByteArray bytes64(8);
    in.getBytes(bytes64);
    coder::Int64 i64(bytes64);
    along = i64.getValue();
    return in;

}

coder::ByteStreamCodec& operator << (coder::ByteStreamCodec& out, uint64_t along) {


    coder::Unsigned64 u64(along);
    out.putBytes(u64.getEncoded());
    return out;

}

coder::ByteStreamCodec& operator >> (coder::ByteStreamCodec& in, uint64_t& along) {

    coder::ByteArray bytes64(8);
    in.getBytes(bytes64);
    coder::Unsigned64 u64(bytes64);
    along = u64.getValue();
    return in;

}

coder::ByteStreamCodec& operator << (coder::ByteStreamCodec& out, const coder::ByteArray& bytes) {

    coder::Unsigned32 u32(static_cast<uint32_t>(bytes.length()));
    out.putBytes(u32.getEncoded());
    out.putBytes(bytes);
    return out;

}

coder::ByteStreamCodec& operator >> (coder::ByteStreamCodec& in, coder::ByteArray& bytes) {

    coder::ByteArray bytes32(4);
    in.getBytes(bytes32);
    coder::Unsigned32 u32(bytes32);
    bytes.setLength(u32.getValue());
    in.getBytes(bytes);
    return in;

}

coder::ByteStreamCodec& operator << (coder::ByteStreamCodec& out, const std::string& str) {

    coder::ByteArray strbytes(str, false);
    out << strbytes;
    return out;

}

coder::ByteStreamCodec& operator >> (coder::ByteStreamCodec& in, std::string& str) {

    coder::ByteArray strbytes;
    in >> strbytes;
    str = strbytes.toLiteralString();
    return in;

}

