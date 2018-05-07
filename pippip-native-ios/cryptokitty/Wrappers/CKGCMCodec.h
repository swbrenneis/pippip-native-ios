//
//  CKGCMCodec.h
//  pippip-native-ios
//
//  Created by Steve Brenneis on 11/30/17.
//  Copyright © 2017 seComm. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CKGCMCodec : NSObject

- (instancetype)initWithData:(NSData*)data;

- (void)decrypt:(NSData*)key withAuthData:(NSData*)authData withError:(NSError**)error;

- (NSData*)encrypt:(NSData*)key withAuthData:(NSData*)authData withError:(NSError**)error;

- (NSData*)getBlock;

- (int32_t)getInt;

- (int64_t)getLong;

- (NSString*)getString;

- (void)putBlock:(NSData*)block;

- (void)putInt:(int32_t)number;

- (void)putLong:(int64_t)number;

- (void)putString:(NSString*)str;

- (void)setIV:(NSData*)iv;

@end
