//
//  CKRSAKeyPair.m
//  CryptoKitty_iOS
//
//  Created by Steve Brenneis on 10/3/17.
//  Copyright © 2017 CryptoKitty. All rights reserved.
//

#import "CKRSAKeyPair.h"

@implementation CKRSAKeyPair

- (instancetype) initWithKeys:(CKRSAPrivateKey*)privateKey withPublicKey:(CKRSAPublicKey*)publicKey {

    self = [super init];
    _privateKey = privateKey;
    _publicKey = publicKey;
    return self;

}

@end
