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

- (instancetype _Nonnull)initWithData:(NSData*_Nonnull)data;

- (void)decrypt:(CKRSAPrivateKey*_Nonnull)key error:(NSError*_Nullable*_Nonnull)error;

- (NSData*_Nonnull)encrypt:(CKRSAPublicKey*_Nonnull)key;

- (NSData*_Nonnull)getBlock;

- (NSString*_Nonnull)getString;

- (void)putBlock:(NSData*_Nonnull)block;

- (void)putString:(NSString*_Nonnull)str;

@end
