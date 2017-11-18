#ifndef BIGINTEGER_H_INCLUDED
#define BIGINTEGER_H_INCLUDED

#include "gmp.h"
#include <iostream>

namespace coder {
    class ByteArray;
}

class Random;

/*
 *
 */
class BigInteger {

    public:
        static const BigInteger ZERO;
        static const BigInteger ONE;

    public:
        class DivideByZeroException {
            public:
                DivideByZeroException() {}
                ~DivideByZeroException() {}
        };

    public:
        // Constructs a BigInteger object with a value of 0 
        BigInteger();
        BigInteger(const BigInteger& other);
        // Constructs a BigInteger from a bigendian encoded byte array.
        BigInteger(const coder::ByteArray& bytes);
        // Constructs a BigInteger object with initial unsigned long value
        BigInteger(unsigned long intial);
        // Constructs a BigInteger object with a probablistic
        // prime value. If sgPrime = true, the number will be
        // a safe prime.
        BigInteger(int bits, bool sgPrime, Random& rnd);

    private:
        BigInteger(mpz_t newNumber);
        explicit BigInteger(const mpz_t otherNumber);

    public:
        BigInteger& operator= (const BigInteger& other);
        BigInteger& operator= (unsigned long value);
        BigInteger& operator++ ();
        BigInteger operator++ (int i);

    public:
        ~BigInteger();

    public:
        // Returns a BigInteger that is the sum of this and addend.
        BigInteger add(const BigInteger& addend) const;
        // Returns a BigInteger that is the bitwise and of this
        // and logical.
        BigInteger And(const BigInteger& logical) const;
        // Returns the number of significant bits.
        size_t bitLength() const;
        // Returns the total number of bits
        size_t bitSize() const;
        // Decode a byte array
        void decode(const coder::ByteArray& bytes);
        // Returns a BigInteger equal to this divided by divisor.
        BigInteger divide(const BigInteger& divisor) const;
        // Returns true if this = other.
        bool equals(const BigInteger& other) const;
        // Returns the greatest common denominator of this and a.
        BigInteger gcd(const BigInteger& a) const;
        // Returns a coder::ByteArray in the specified encoding.
        coder::ByteArray getEncoded() const;
        // Returns a BigInteger that is the bitwise inversion of this.
        BigInteger invert() const;
        // Returns true if the integer is a probable prime.
        bool isProbablePrime() const;
        // Returns a BigInteger equal to this shifted left count times.
        BigInteger leftShift(long count) const;
        // Returns true if this < other.
        bool lessThan(const BigInteger& other) const;
        // Returns a BigInteger equal to this mod a.
        BigInteger mod(const BigInteger& a) const;
        // Returns the modular inverse. x = a^{-1} mod n. Throws a
        // Data exception if a = 0 or if a and n are not coprime.
        BigInteger modInverse(const BigInteger& n) const;
        // Returns BigInteger equal to this**exp mod m.
        BigInteger modPow(const BigInteger& exp, const BigInteger& m) const;
        // Returns a BigInteger equal to this * multiplier.
        BigInteger multiply(const BigInteger& multiplier) const;
        // Returns a BigInteger that is the bitwise or of this
        // and logical.
        BigInteger Or(const BigInteger& logical) const;
        // Returns a BigInteger equal to this raised to the exp power.
        BigInteger pow(unsigned long exp) const;
        // Returns a BigInteger equal to this shifted right count times.
        BigInteger rightShift(long count) const;
        // Set a bit
        void setBit(int bitnum);
        // Returns a BigInteger equal to this minus subtractor.
        BigInteger subtract(const BigInteger& subtractor) const;
        // Returns true if the specified bit is set.
        bool testBit(int bitnum) const;
        // Returns the long representation of this integer. May be truncated.
        unsigned long toLong();
        // Returns a BigInteger that is the bitwise exclusive or of this
        // and logical.
        BigInteger Xor(const BigInteger& logical) const;

    public:
        void out(std::ostream& o) const;

    private:
        mpz_t number;

        static const unsigned long long ULLONG_MSB;

};

/*
 * Global operator overloads
*/
bool operator== (const BigInteger& lhs, const BigInteger& rhs);
bool operator!= (const BigInteger& lhs, const BigInteger& rhs);
bool operator< (const BigInteger& lhs, const BigInteger& rhs);
bool operator<= (const BigInteger& lhs, const BigInteger& rhs);
bool operator> (const BigInteger& lhs, const BigInteger& rhs);
bool operator>= (const BigInteger& lhs, const BigInteger& rhs);
BigInteger operator+ (const BigInteger& lhs, const BigInteger& rhs);
BigInteger operator- (const BigInteger& lhs, const BigInteger& rhs);
BigInteger operator- (const BigInteger& lhs);
BigInteger operator* (const BigInteger& lhs, const BigInteger& rhs);
BigInteger operator/ (const BigInteger& lhs, const BigInteger& rhs);
BigInteger operator% (const BigInteger& lhs, const BigInteger& rhs);
BigInteger operator^ (const BigInteger& lhs, const BigInteger& rhs);
BigInteger operator| (const BigInteger& lhs, const BigInteger& rhs);
BigInteger operator& (const BigInteger& lhs, const BigInteger& rhs);
BigInteger operator~ (const BigInteger& lhs);
BigInteger operator>> (const BigInteger& lhs, long rhs);
BigInteger operator<< (const BigInteger& lhs, long rhs);
std::ostream& operator<< (std::ostream& out, const BigInteger& bi);

#endif // BIGINTEGER_H_INCLUDED
