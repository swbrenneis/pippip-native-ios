//
//  Configurator.h
//  pippip-native-ios
//
//  Created by Steve Brenneis on 2/12/18.
//  Copyright © 2018 seComm. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Configurator : NSObject

@property (nonatomic) NSArray<NSDictionary*> *whitelist;

- (BOOL)addWhitelistEntry:(NSDictionary*)entity;

- (BOOL)deleteWhitelistEntry:(NSString*)publicId;

- (NSString*)getContactPolicy;

- (NSString*)getNickname;

- (void)loadWhitelist;

- (NSInteger)newContactId;

- (NSInteger)newMessageId;

- (void)setContactPolicy:(NSString*)policy;

- (void)setNickname:(NSString*)nickname;

- (BOOL)storeCleartextMessages;

- (void)storeCleartextMessages:(BOOL)cleartext;

- (BOOL)useLocalAuth;

- (void)useLocalAuth:(BOOL)localAuth;

- (NSInteger)whitelistIndexOf:(NSString*)publicId;

@end
