//
//  CKGCMCodec.h
//  pippip-native-ios
//
//  Created by Steve Brenneis on 11/30/17.
//  Copyright © 2017 seComm. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CKGCMCodec : NSObject

@property (nonatomic) NSString *_Nullable lastError;

- (instancetype _Nonnull)initWithData:(NSData*_Nonnull)data;

- (BOOL)decrypt:(NSData*_Nonnull)key withAuthData:(NSData*_Nonnull)authData error:(NSError*_Nullable*_Nonnull)error;

- (NSData*_Nullable)encrypt:(NSData*_Nonnull)key withAuthData:(NSData*_Nonnull)authData;

- (NSData*_Nonnull)getBlock;

- (NSInteger)getInt;

- (NSString*_Nonnull)getString;

- (void)putBlock:(NSData*_Nonnull)block;

- (void)putInt:(NSInteger)number;

- (void)putString:(NSString*_Nonnull)str;

- (void)setIV:(NSData*_Nonnull)iv;

@end
