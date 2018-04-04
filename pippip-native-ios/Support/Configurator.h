//
//  Configurator.h
//  pippip-native-ios
//
//  Created by Steve Brenneis on 2/12/18.
//  Copyright © 2018 seComm. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SessionState;

@interface Configurator : NSObject

@property (nonatomic) NSArray<NSDictionary*> *whitelist;

- (void)addContactId:(NSInteger)contactId withPublicId:(NSString*)publicId;

- (BOOL)addWhitelistEntry:(NSDictionary*)entity;

- (NSArray*)allContactIds;

- (void)deleteContactId:(NSString*)publicId;

- (BOOL)deleteWhitelistEntry:(NSString*)publicId;

- (BOOL)getCleartextMessages;

- (NSInteger)getContactId:(NSString*)publicId;

- (NSString*)getContactPolicy;

- (NSInteger)getNextMessageSequence;

- (NSString*)getNickname;

- (void)loadWhitelist;

- (NSInteger)newContactId;

- (NSInteger)newMessageId;

- (void)setCleartextMessages:(BOOL)cleartext;
    
- (void)setContactPolicy:(NSString*)policy;

- (void)setNickname:(NSString*)nickname;

- (NSInteger)whitelistIndexOf:(NSString*)publicId;

@end
