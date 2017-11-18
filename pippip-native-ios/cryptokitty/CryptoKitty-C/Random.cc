#include "Random.h"
#include <climits>
#include <cmath>

/*
 * For iOS, this is just a shell class. It does nothing.
 */
Random::Random() {
}

Random::~Random() {
}

uint64_t Random::next(int bits) {

    return 0;
    
}

void Random::nextBytes(coder::ByteArray& bytes) {
}

uint32_t Random::nextInt() {

    return 0;

}

uint64_t Random::nextLong() {

    return 0;

}

/*
 * Does nothing.
 */
void Random::setSeed(uint64_t newSeed) {
}
