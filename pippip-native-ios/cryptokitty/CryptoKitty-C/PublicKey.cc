#include "PublicKey.h"

PublicKey::PublicKey(const std::string& alg)
: algorithm(alg) {
}

PublicKey::~PublicKey() {
}

const std::string& PublicKey::getAlgorithm() const {

    return algorithm;

}
