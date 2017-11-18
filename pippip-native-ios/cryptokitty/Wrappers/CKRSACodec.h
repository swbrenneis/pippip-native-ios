//
//  CKRSACodec.h
//  CryptoKitty_iOS
//
//  Created by Steve Brenneis on 10/10/17.
//  Copyright © 2017 CryptoKitty. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CKRSAPrivateKey.h"
#import "CKRSAPublicKey.h"

@interface CKRSACodec : NSObject

- (instancetype)initWithData:(NSData*)data;

- (void)decrypt:(CKRSAPrivateKey*)key withError:(NSError**) error;

- (NSData*)encrypt:(CKRSAPublicKey*)key;

- (NSData*)getBlock;

- (NSString*)getString;

- (void)putBlock:(NSData*)block;

- (void)putString:(NSString*)str;

@end
