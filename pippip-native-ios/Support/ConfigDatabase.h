//
//  Configurator.h
//  pippip-native-ios
//
//  Created by Steve Brenneis on 2/12/18.
//  Copyright © 2018 seComm. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AccountConfig;

@interface ConfigDatabase : NSObject

@property (nonnull, nonatomic) NSArray<NSDictionary*> *whitelist;

- (BOOL)addWhitelistEntry:(nonnull NSDictionary*)entity;

- (BOOL)deleteWhitelistEntry:(nonnull NSString*)publicId;

- (nonnull AccountConfig*)getConfig;

// - (nonnull NSString*)getContactPolicy;

// - (nonnull NSString*)getNickname;

- (void)loadWhitelist;

- (NSInteger)newContactId;

- (NSInteger)newMessageId;

- (void)setContactPolicy:(nonnull NSString*)policy;

- (void)setNickname:(nullable NSString*)nickname;

// - (BOOL)storeCleartextMessages;

- (void)storeCleartextMessages:(BOOL)cleartext;

// - (BOOL)useLocalAuth;

- (void)useLocalAuth:(BOOL)localAuth;

- (NSInteger)whitelistIndexOf:(nonnull NSString*)publicId;

@end
