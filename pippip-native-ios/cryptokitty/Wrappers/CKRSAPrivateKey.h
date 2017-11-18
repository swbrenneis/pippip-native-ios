//
//  CKRSAPrivateKey.h
//  CryptoKitty_iOS
//
//  Created by Steve Brenneis on 10/3/17.
//  Copyright © 2017 CryptoKitty. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CKRSAPrivateKey : NSObject

@property (nonatomic) int bitLength;
@property (nonatomic, readonly) void *privateKey;

- (instancetype) initWithKey:(void*)key;

@end
