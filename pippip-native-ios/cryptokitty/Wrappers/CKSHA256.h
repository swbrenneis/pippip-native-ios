//
//  CKSHA256.h
//  CryptoKitty_iOS
//
//  Created by Steve Brenneis on 10/4/17.
//  Copyright © 2017 CryptoKitty. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CKSHA256 : NSObject

- (instancetype _Nonnull) init;

- (void) dealloc;

- (NSData*_Nonnull) digest;

- (NSData*_Nonnull) digest:(NSData*_Nonnull)data;

- (void) reset;

- (void) update:(NSData*_Nonnull)data;

@end
