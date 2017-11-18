//
//  CKRSAPublicKey.m
//  CryptoKitty_iOS
//
//  Created by Steve Brenneis on 10/3/17.
//  Copyright © 2017 CryptoKitty. All rights reserved.
//

#import "CKRSAPublicKey.h"

@implementation CKRSAPublicKey

- (instancetype) initWithKey:(void*)key {
    
    self = [super init];
    _publicKey = key;
    return self;
    
}

@end
