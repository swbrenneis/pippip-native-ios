#include "RSAPrivateKey.h"

RSAPrivateKey::RSAPrivateKey(KeyType kt)
: PrivateKey("RSA"),
  keyType(kt) {
}

RSAPrivateKey::~RSAPrivateKey() {
}

