//
//  CKRSAPrivateKey.m
//  CryptoKitty_iOS
//
//  Created by Steve Brenneis on 10/3/17.
//  Copyright © 2017 CryptoKitty. All rights reserved.
//

#import "CKRSAPrivateKey.h"

@implementation CKRSAPrivateKey

- (instancetype) initWithKey:(void*)key {

    self = [super init];
    _privateKey = key;
    return self;

}

@end
