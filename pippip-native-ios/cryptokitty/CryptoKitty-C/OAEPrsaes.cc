#include "OAEPrsaes.h"
#include "PSSmgf1.h"
#include "RSAPrivateKey.h"
#include "RSAPublicKey.h"
#include "SHA1.h"
#include "SHA256.h"
#include "SHA384.h"
#include "SHA512.h"
#include "IllegalOperationException.h"
#include "DecryptionException.h"
#include "BadParameterException.h"
#include <memory>

OAEPrsaes::OAEPrsaes(HashAlgorithm ha)
: algorithm(ha),
  label(0),
  seed(0) {

      switch (algorithm) {
          case sha1:
              digest = new SHA1;
              break;
          case sha256:
              digest = new SHA256;
              break;
          case sha384:
              digest = new SHA384;
              break;
          case sha512:
              digest = new SHA512;
              break;
          default:
              throw BadParameterException("Invalid hash algorithm");
      }

}

OAEPrsaes::~OAEPrsaes() {

    delete digest;

}

coder::ByteArray OAEPrsaes::decrypt(const RSAPrivateKey& K, const coder::ByteArray& C) {

    // Length checking.

    // We're supposed to check L to make sure it's not larger than
    // the hash limitation. That is 2^64 - 1 for SHA1 and SHA256, and
    // 2^128 - 1 for SHA384 and SHA512.  X86 processirs can only create 
    // strings that is 2^64 - 1 bytes long. The test would be pointless and
    // technically infeasible.

    // b. If the length of the ciphertext C is not k octets, output
    //    "decryption error" and stop.
    size_t k = K.getBitLength() / 8;
    size_t cLength = C.length();
    if (cLength != k) {
        throw DecryptionException();
    }

    // c. If k < 2hLen + 2, output "decryption error" and stop.
    uint32_t hLen = digest->getDigestLength();
    if (k < (2 * hLen) + 2) {
        throw DecryptionException();
    }

    try {
        BigInteger c = K.rsadp(os2ip(C));
        // Do decoding.
        return emeOAEPDecode(k, i2osp(c, k));
    }
    catch (BadParameterException e) {
        // Catching for debug purposes only.
        // Fail silently.
        throw DecryptionException();
    }

}

coder::ByteArray OAEPrsaes::emeOAEPDecode(size_t k, const coder::ByteArray& EM) {
		
    // a. If the label L (pSource) is not provided, let L be the empty string. Let
    //    lHash = Hash(L), an octet string of length hLen
    coder::ByteArray lHash(digest->digest(label));

    size_t hLen = lHash.length();

    // b. Separate the encoded message EM into a single octet Y, an octet
    //    string maskedSeed of length hLen, and an octet string maskedDB
    //    of length k - hLen - 1 as
    //
    //     EM = Y || maskedSeed || maskedDB.
    uint8_t Y = EM[0];
    coder::ByteArray maskedSeed(EM.range(1, hLen));
    coder::ByteArray maskedDB(EM.range(hLen + 1, k - hLen - 1));

    // c. Let seedMask = MGF(maskedDB, hLen).
    PSSmgf1 mdmgf(digest);
    coder::ByteArray seedMask(mdmgf.generateMask(maskedDB, hLen));

    // d. Let seed = maskedSeed \xor seedMask.
    coder::ByteArray seed(maskedSeed ^ seedMask);

    // e. Let dbMask = MGF(seed, k - hLen - 1).
    PSSmgf1 dbmgf(digest);
    coder::ByteArray dbMask(dbmgf.generateMask(seed, k - hLen - 1));

    // f. Let DB = maskedDB \xor dbMask.
    coder::ByteArray DB(maskedDB ^ dbMask);

    // g. Separate DB into an octet string lHash' of length hLen, a
    //    (possibly empty) padding string PS consisting of octets with
    //    hexadecimal value 0x00, and a message M as
    //
    //      DB = lHash' || PS || 0x01 || M.
    //
    // If there is no octet with hexadecimal value 0x01 to separate PS
    // from M, if lHash does not equal lHash', or if Y is nonzero,
    // output "decryption error" and stop.
    if (Y != 0) {
        throw DecryptionException();
    }
    coder::ByteArray lHashPrime(DB.range(0, hLen));
    if (lHash != lHashPrime) {
        throw DecryptionException();
    }
    
    bool found = false;
    // The 0x01 byte has to be at the length of the hash + the original size of PS + 1
    // The original size of PS is k - mLen - (2 * hLen) - 2
    // k = the size of the key in bytes.
    // mLen is the length of M (original message).
    // hLen is the size of the digest in bytes.
    size_t index = hLen;
    while (!found && index < DB.length()) {
        // PS should be all zeros, so the 0x01 byte should be the first non-zero byte.
        if (DB[index] == 0x01) {
            found = true;
        }
        else if (DB[index] != 0) {
            throw DecryptionException();
        }
        else {
            index++;
        }
    }
    if (!found) {
        throw DecryptionException();				
    }
    coder::ByteArray PS(DB.range(hLen, index - hLen));
    coder::ByteArray M(DB.range(hLen + PS.length() + 1));
    if (PS.length() != (k - M.length() - (2 * hLen) - 2)) {
        throw DecryptionException();
    }

    return M;

}

coder::ByteArray OAEPrsaes::emeOAEPEncode(size_t k, const coder::ByteArray&  M) {

    // a. If the label L is not provided, let L be the empty string. Let
    //    lHash = Hash(L), an octet string of length hLen
    coder::ByteArray lHash(digest->digest(label));

    // b. Generate an octet string PS consisting of k - mLen - 2hLen - 2
    // zero octets.  The length of PS may be zero.
    uint32_t hLen = digest->getDigestLength();
    size_t mLen = M.length();
    coder::ByteArray PS(k - mLen - (2 * hLen) - 2, 0);

    // c. Concatenate lHash, PS, a single octet with hexadecimal value
    //    0x01, and the message M to form a data block DB of length k -
    //    hLen - 1 octets as
    //
    //      DB = lHash || PS || 0x01 || M.
    coder::ByteArray DB;
    DB.append(lHash);
    DB.append(PS);
    DB.append(0x01);
    DB.append(M);

    // d. Generate a random octet string seed of length hLen.
    // The seed is provided to the constructor.
    if (seed.length() != digest->getDigestLength()) {
        throw BadParameterException("Invalid seed length");
    }


    // e. Let dbMask = MGF(seed, k - hLen - 1).
    PSSmgf1 dmgf(digest);
    coder::ByteArray dbMask(dmgf.generateMask(seed, k - hLen - 1));

    // f. Let maskedDB = DB \xor dbMask.
    coder::ByteArray maskedDB(DB ^ dbMask);

    // g. Let seedMask = MGF(maskedDB, hLen).
    PSSmgf1 smgf(digest);
    coder::ByteArray seedMask(smgf.generateMask(maskedDB, hLen));

    // h. Let maskedSeed = seed \xor seedMask.
    coder::ByteArray maskedSeed(seed ^  seedMask);

    // i. Concatenate a single octet with hexadecimal value 0x00,
    //    maskedSeed, and maskedDB to form an encoded message EM of
    //    length k octets as
    //
    //       EM = 0x00 || maskedSeed || maskedDB.
    coder::ByteArray EM;
    EM.append(0x00);
    EM.append(maskedSeed);
    EM.append(maskedDB);

    return EM;

}

coder::ByteArray OAEPrsaes::encrypt(const RSAPublicKey& K, const coder::ByteArray& P) {

    // Length checking.

    // We're supposed to check L to make sure it's not larger than
    // the hash limitation. That is 2^64 - 1for SHA1 and SHA256, and
    // 2^128 - 1 for SHA384 and SHA512. Java can only create a string
    // that is 2^31 - 1 bytes long. The test would be pointless and
    // technically infeasible.

    uint32_t hLen = digest->getDigestLength();
    size_t k = K.getBitLength() / 8;
    size_t mLen = P.length();
    if (mLen > k - (2 * hLen) - 2) {
        throw BadParameterException("Message too long");
    }
    // We're supposed to check L to make sure it's not larger than
    // the hash limitation, which is ginormous for SHA-1 and above
    // (~= 2 exabytes). Not going to worry about it.

    // Do encoding first.
    coder::ByteArray EM(emeOAEPEncode(k, P));
    // Do encryption primitive
    BigInteger c = rsaep(K, os2ip(EM));
    // Return octet string.
    coder::ByteArray cb(c.getEncoded());
    //std::cout << "cb = " << cb.toString() << std::endl;
    return i2osp(c, k);

}

void OAEPrsaes::setSeed(const coder::ByteArray& s) {

    if (s.length() != digest->getDigestLength()) {
        throw BadParameterException("Invalid seed length");
    }
    seed = s;

}

coder::ByteArray OAEPrsaes::sign(const RSAPrivateKey& K, const coder::ByteArray& M) {
    throw IllegalOperationException("Unsupported encryption operation");
}

bool OAEPrsaes::verify(const RSAPublicKey& K, const coder::ByteArray& M,
                                                            const coder::ByteArray& S) {
    throw IllegalOperationException("Unsupported enryption operation");
}
