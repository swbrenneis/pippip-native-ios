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

- (instancetype)initWithSessionState:(SessionState*)state;

- (BOOL)addWhitelistEntry:(NSDictionary*)entity;

- (BOOL)deleteWhitelistEntry:(NSString*)publicId;

- (NSString*)getContactPolicy;

- (NSInteger)getMessageId;

- (NSString*)getNickname;

- (void)setContactPolicy:(NSString*)policy;

- (void)setNickname:(NSString*)nickname;

@end
