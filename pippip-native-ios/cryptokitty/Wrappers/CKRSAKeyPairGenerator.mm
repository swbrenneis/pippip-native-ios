//
//  CKRSAKeyPairGenerator.m
//  CryptoKitty_iOS
//
//  Created by Steve Brenneis on 10/3/17.
//  Copyright © 2017 CryptoKitty. All rights reserved.
//

#import "CKRSAKeyPairGenerator.h"
#import "RSAKeyPairGenerator.h"
#import "KeyPair.h"
#import "IosSecureRandom.h"

@implementation CKRSAKeyPairGenerator

- (CKRSAKeyPair*) generateKeyPair:(int)bitsize {

    RSAKeyPairGenerator keyGen;
    IosSecureRandom rnd;
    keyGen.initialize(bitsize, &rnd);
    RSAKeyPair *pair = keyGen.generateKeyPair();
    RSAPublicKey *pubKey = pair->publicKey();
    RSAPrivateKey *prvKey = pair->privateKey();
    pair->releaseKeys();
    CKRSAPublicKey *publicKey = [[CKRSAPublicKey alloc] initWithKey:pubKey];
    CKRSAPrivateKey *privateKey = [[CKRSAPrivateKey alloc] initWithKey:prvKey];

    return [[CKRSAKeyPair alloc] initWithKeys:privateKey withPublicKey:publicKey];

}

@end
