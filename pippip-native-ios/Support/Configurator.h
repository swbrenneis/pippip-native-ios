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

//- (NSArray<NSNumber*>*)allContactIds;

//- (void)deleteContactId:(NSString*)publicId;

- (BOOL)deleteWhitelistEntry:(NSString*)publicId;

- (BOOL)getCleartextMessages;

//- (NSInteger)getContactId:(NSString*)publicId;

- (NSString*)getContactPolicy;

- (NSString*)getNickname;

- (void)loadWhitelist;

- (NSInteger)newContactId;

- (NSInteger)newMessageId;

- (void)setCleartextMessages:(BOOL)cleartext;
    
- (void)setContactPolicy:(NSString*)policy;

- (void)setNickname:(NSString*)nickname;

- (NSInteger)whitelistIndexOf:(NSString*)publicId;

@end
