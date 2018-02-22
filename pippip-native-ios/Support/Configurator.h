//
//  Configurator.h
//  pippip-native-ios
//
//  Created by Steve Brenneis on 2/12/18.
//  Copyright © 2018 seComm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SessionState.h"

@interface Configurator : NSObject

@property (nonatomic) NSArray *whitelist;

- (void)addContactId:(NSInteger)contactId withPublicId:(NSString*)publicId;

- (BOOL)addWhitelistEntry:(NSDictionary*)entity;

- (NSArray*)allContactIds;

- (void)deleteContactId:(NSString*)publicId;

- (BOOL)deleteWhitelistEntry:(NSString*)publicId;

- (NSInteger)getContactId:(NSString*)publicId;

- (NSString*)getContactPolicy;

- (NSString*)getNickname;

- (void)loadWhitelist;

- (NSInteger)newContactId;

- (NSInteger)newMessageId;

- (void)setContactPolicy:(NSString*)policy;

- (void)setNickname:(NSString*)nickname;

- (void)startNewSession:(SessionState*)state;

@end
