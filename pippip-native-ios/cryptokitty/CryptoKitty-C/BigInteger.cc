#include "BigInteger.h"
#include "Random.h"
#include "BadParameterException.h"
#include "ByteArray.h"
#include <algorithm>
#include <climits>
#include <cmath>
//#include "GMP_iOS/ZZ.h"

/*
 * Static initialization
 */
const BigInteger BigInteger::ZERO;
const BigInteger BigInteger::ONE(1);
const unsigned long long
    BigInteger::ULLONG_MSB = (ULLONG_MAX >> 1) ^ ULLONG_MAX;

/* Uses small coprime test, 64 rounds of Miller-Rabin, and
 * tests for Sophie Germain primality, if indicated.
 */ 
void makePrime(mpz_t n, bool sgPrime) {

    if (mpz_probab_prime_p(n, 64) != 1) {
        mpz_nextprime(n, n);
    }

    // Increment until we get the SG prime.
    if (sgPrime) {
        mpz_t sg;
        mpz_init(sg);
        mpz_mul_ui(sg, n, 2);
        mpz_add_ui(sg, sg, 1);
        if (mpz_probab_prime_p(sg, 64) != 1) {
            mpz_add_ui(n, n, 2);
            makePrime(n, true);
        }
        mpz_clear(sg);
    }

}

/*
 * Default constructor
 * Sets value to 0
 */
BigInteger::BigInteger() {

    mpz_init(number);

}

/*
 * Copy constructor
 */
BigInteger::BigInteger(const BigInteger& other) {

    mpz_init_set(number, other.number);

}

/*
 * Constructor with initial unsigned long value
 */
BigInteger::BigInteger(unsigned long initial) {

    mpz_init_set_ui(number, initial);

}

/*
 * Construct a BigInteger from a byte array
 */
BigInteger::BigInteger(const coder::ByteArray& bytes) {

    mpz_init(number);
    decode(bytes);

}

/*
 * Construct a BigInteger that is a probabilistic random prime, with the specified
 * length. The prime is tested with 64 Miller-Rabin rounds after some small prime
 * tests. The prime will also be a Sophie Germain prime if the boolean is true
 * (p and 2p+2 both prime). Selecting Germain primes is very time-consuming.
 */
BigInteger::BigInteger(int bits, bool sgPrime, Random& rnd) {

    if (bits == 0) {
        throw BadParameterException("Invalid bit length");
    }

    double dbits = bits;
    coder::ByteArray pBytes(ceil(dbits / 8));
    rnd.nextBytes(pBytes);

    // Load the big integer.
    mpz_t work;
    mpz_init_set_ui(work, pBytes[0]);
    for (unsigned n = 1; n < pBytes.length(); ++n) {
        mpz_mul_ui(work, work, 256);
        mpz_add_ui(work, work, pBytes[n]);
    }

    // Make sure it's positive.
    mpz_abs(work, work);

    // Make sure it's odd.
    if (mpz_odd_p(work) == 0) {
        mpz_add_ui(work, work, 1);
    }

    makePrime(work, sgPrime);
    mpz_init_set(number, work);
    mpz_clear(work);

}

/*
 * Construct a BigInteger with a new GMP integer. Clears the input integer.
 * This effectively consumes the input integer.
 */
BigInteger::BigInteger(mpz_t newNumber) {

    mpz_init_set(number, newNumber);
    mpz_clear(newNumber);

}

/*
 * Construct a BigInteger with a copy of a GMP integer.
 */
BigInteger::BigInteger(const mpz_t otherNumber) {

    mpz_init_set(number, otherNumber);
    
}

/*
 * Destructor
 */
BigInteger::~BigInteger() {

    mpz_clear(number);

}

/*
 * Assignment operator
 */
BigInteger& BigInteger::operator= (const BigInteger& other) {

    mpz_clear(number);
    mpz_init_set(number, other.number);
    return *this;

}

/*
 * Assignment operator
 */
BigInteger& BigInteger::operator= (unsigned long value) {

    mpz_clear(number);
    mpz_init_set_ui(number, value);
    return *this;

}

/*
 * Prefix increment.
 */
BigInteger& BigInteger::operator++ () {

    mpz_add_ui(number, number, 1);
    return *this;

}

/*
 * Postfix increment.
 */
BigInteger BigInteger::operator++ (int) {

    BigInteger x = *this;
    ++(*this);
    return x;

}

/*
 * Returns a BigInteger equal to this plus addend.
 */
BigInteger BigInteger::add(const BigInteger& addend) const {

    mpz_t result;
    mpz_init(result);
    mpz_add(result, number, addend.number);
    return result;

}

/*
 * Returns a BigInteger equal to bitwise and of this and logical.
 */
BigInteger BigInteger::And(const BigInteger& logical) const {

    mpz_t result;
    mpz_init(result);
    mpz_and(result, number, logical.number);
    return result;

}

/*
 * Returns the number of bits in the binary representation of this integer.
 */
size_t BigInteger::bitLength() const {

    return mpz_sizeinbase(number, 2);

}

/*
 * Returns the number of bit in the encoded representation of this integer.
 */
size_t BigInteger::bitSize() const {

    coder::ByteArray enc(getEncoded());
    return enc.length() * 8;

}

/*
 * Decode a byte array with the indicated byte order.
 * Assumes that the GMP integer has been initialized.
 */
void BigInteger::decode(const coder::ByteArray& bytes) {

    size_t bl = bytes.length(); // have to do this so the indexes
                                // don't wrap.

    for (int n = 0; n < bl; ++n) {
        mpz_mul_ui(number, number, 256);
        mpz_add_ui(number, number, bytes[n]);
    }

}

/*
 * returns a BigInteger that is eual to this divided by divisor.
 */
BigInteger BigInteger::divide(const BigInteger& divisor) const {

    if (divisor == ZERO) {
        throw BadParameterException("Divide by zero");
    }
    
    mpz_t result;
    mpz_init(result);
    mpz_tdiv_q(result, number, divisor.number);
    return result;

}

/*
 * Returns true if this = other.
 */
bool BigInteger::equals(const BigInteger& other) const {

    return mpz_cmp(number, other.number) == 0;

}

/*
 * Returns the greatest common denominator of this and a.
 */
BigInteger BigInteger::gcd(const BigInteger& a) const {

    mpz_t result;
    mpz_init(result);
    mpz_gcd(result, number, a.number);
    return result;

}

/*
 * Encodes the absolute value of the integer into an array
 * in the specified byte order.
 */
coder::ByteArray BigInteger::getEncoded() const {

    mpz_t work;
    mpz_init(work);
    mpz_abs(work, number);
    double bl = bitLength();
    int index = ceil(bl / 8);
    if (index == 0) {
        return coder::ByteArray(1,0);
    }
    coder::ByteArray result;
    while (index > 0) {
        unsigned long byte = mpz_fdiv_ui(work, 256);
        result.push(byte & 0xff);
        mpz_tdiv_q_ui(work, work, 256);
        index --;
    }
    // If the MSB is set in the lowest octet, we need to add
    // a sign byte so that the value is always positive.
    if ((result[0] & 0x80) != 0) {
        result.push(0);
    }
    return result;

}

/*
 * Returns a BigInteger that is the bitwise inversion (1s complement) of this.
 */
BigInteger BigInteger::invert() const {

    mpz_t result;
    mpz_init(result);
    mpz_com(result, number);
    return result;

}

/*
 * Returns true if the integer is probably prime. Performs 64 Miller-Rabin iterations.
 */
bool BigInteger::isProbablePrime() const {

    return mpz_probab_prime_p(number, 64) == 1;

}

/*
 * Returns a BigInteger that is this shifted left count times.
 */
BigInteger BigInteger::leftShift(long count) const {

    mpz_t result;
    mpz_init_set(result, number);
    long shifted = 0;
    while (shifted++ < count) {
        mpz_mul_ui(result, result, 2);
    }
    return result;

}

/*
 * Returns true if this < other.
 */
bool BigInteger::lessThan(const BigInteger& other) const {

    return mpz_cmp(number, other.number) < 0;

}

/*
 * Returns a BigInteger object that is the remainder of this divided by a.
 */
BigInteger BigInteger::mod(const BigInteger& a) const {

    if (a == ZERO) {
        throw BadParameterException("Divide by zero");
    }
    
    mpz_t result;
    mpz_init(result);
    mpz_mod(result, number, a.number);
    return result;

}

/*
 * Returns a BigInteger that is equal to the modular inverse of this.
 * This and n must be coprime.
 */
BigInteger BigInteger::modInverse(const BigInteger& n) const {

    if (n == ZERO) {
        throw BadParameterException("Invalid modulus for inversion");
    }

    mpz_t result;
    mpz_init(result);
    int res = mpz_invert(result, number, n.number);
    
    if (res == 0) {
        mpz_clear(result);
        throw BadParameterException("Inverse does not exist");
    }

    return result;

}

/*
 * Returns a BigInteger that is equal to (this**exp) % m.
 */
BigInteger BigInteger::modPow(const BigInteger& exp,
                const BigInteger& m) const {

    // Solve for negative exponents using modular multiplicative
    // inverse.
    if (exp < ZERO) {
        return modInverse(m);
    }

    mpz_t result;
    mpz_init(result);
    mpz_powm(result, number, exp.number, m.number);
    return result;

}

/*
 * Returns a BigInteger that is the product of this and multiplier.
 */
BigInteger BigInteger::multiply(const BigInteger& multiplier) const {

    mpz_t result;
    mpz_init(result);
    mpz_mul(result, number, multiplier.number);
    return result;

}

/*
 * Returns a BigInteger equal to bitwise or of this and logical.
 */
BigInteger BigInteger::Or(const BigInteger& logical) const {

    mpz_t result;
    mpz_init(result);
    mpz_ior(result, number, logical.number);
    return result;

}

/*
 * Send the value to a standard output stream.
 */
void BigInteger::out(std::ostream& o) const {

    std::unique_ptr<char[]> str(mpz_get_str(0, 10, number));
    o << std::string(str.get());

}

/*
 * Returns a BigInteger equal to this**exp.
 */
BigInteger BigInteger::pow(unsigned long exp) const {

    mpz_t result;
    mpz_init(result);
    mpz_pow_ui(result, number, exp);
    return result;

}

/*
 * Returns a BigInteger that is this shifted right count times.
 */
BigInteger BigInteger::rightShift(long count) const {


    mpz_t result;
    mpz_init_set(result, number);
    long shifted = 0;
    while (shifted++ < count) {
        mpz_tdiv_q_ui(result, result, 2);
    }
    return result;
    

}

/*
 * Sets the bit indicated by bitnum.
 */
void BigInteger::setBit(int bitnum) {

    mpz_setbit(number, bitnum);

}

/*
 * Returns a BigInteger equal to this minus subtractor.
 */
BigInteger BigInteger::subtract(const BigInteger& subtractor) const {

    mpz_t result;
    mpz_init(result);
    mpz_sub(result, number, subtractor.number);
    return result;
    
}

/*
 * Returns true if the specified bit is set.
 */
bool BigInteger::testBit(int bitnum) const {

    return mpz_tstbit(number, bitnum) == 1;

}

/*
 * Returns a long (64 bit) representation of this integer.
 */
unsigned long BigInteger::toLong() {

    return mpz_get_ui(number);

}

/*
 * Returns a BigInteger equal to bitwise xor of this and logical.
 */
BigInteger BigInteger::Xor(const BigInteger& logical) const {

    mpz_t result;
    mpz_init(result);
    mpz_xor(result, number, logical.number);
    return result;
    
}

// Global operators
bool operator== (const BigInteger& lhs, const BigInteger& rhs)
{ return lhs.equals(rhs); }
bool operator!= (const BigInteger& lhs, const BigInteger& rhs)
{ return !lhs.equals(rhs); }
bool operator< (const BigInteger& lhs, const BigInteger& rhs)
{ return lhs.lessThan(rhs); }
bool operator<= (const BigInteger& lhs, const BigInteger& rhs)
{ return lhs.lessThan(rhs) || lhs.equals(rhs); }
bool operator> (const BigInteger& lhs, const BigInteger& rhs)
{ return !lhs.lessThan(rhs) && !lhs.equals(rhs); }
bool operator>= (const BigInteger& lhs, const BigInteger& rhs)
{ return !lhs.lessThan(rhs); }
BigInteger operator- (const BigInteger& lhs, const BigInteger& rhs)
{ return lhs.subtract(rhs); }
BigInteger operator- (const BigInteger& lhs)
{ return BigInteger::ZERO.subtract(lhs); }
BigInteger operator+ (const BigInteger& lhs, const BigInteger& rhs)
{ return lhs.add(rhs); }
BigInteger operator* (const BigInteger& lhs, const BigInteger& rhs)
{ return lhs.multiply(rhs); }
BigInteger operator/ (const BigInteger& lhs, const BigInteger& rhs)
{ return lhs.divide(rhs); }
BigInteger operator% (const BigInteger& lhs, const BigInteger& rhs)
{ return lhs.mod(rhs); }
BigInteger operator^ (const BigInteger& lhs, const BigInteger& rhs)
{ return lhs.Xor(rhs); }
BigInteger operator| (const BigInteger& lhs, const BigInteger& rhs)
{ return lhs.Or(rhs); }
BigInteger operator& (const BigInteger& lhs, const BigInteger& rhs)
{ return lhs.And(rhs); }
BigInteger operator~ (const BigInteger& lhs)
{ return lhs.invert(); }
BigInteger operator<< (const BigInteger& lhs, long rhs)
{ return lhs.leftShift(rhs); }
BigInteger operator>> (const BigInteger& lhs, long rhs)
{ return lhs.rightShift(rhs); }
std::ostream& operator<< (std::ostream& out, const BigInteger& bi)
{ bi.out(out); return out; }
