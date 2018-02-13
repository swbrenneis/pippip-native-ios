//
//  Configurator.m
//  pippip-native-ios
//
//  Created by Steve Brenneis on 2/12/18.
//  Copyright © 2018 seComm. All rights reserved.
//

#import "Configurator.h"
#import "AccountConfig.h"
#import "CKGCMCodec.h"
#import <Realm/Realm.h>

@interface Configurator ()
{
    AccountConfig *config;
    NSMutableArray *privateWhitelist;
}

@property (weak, nonatomic) SessionState *sessionState;

@end

@implementation Configurator

- (instancetype)initWithSessionState:(SessionState *)state {
    self = [super init];

    _sessionState = state;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"accountName = %@", state.currentAccount];
    RLMResults<AccountConfig*> *configResults = [AccountConfig objectsWithPredicate:predicate];
    config = [configResults firstObject];
    privateWhitelist = [NSMutableArray array];
    _whitelist = privateWhitelist;

    return self;

}

- (BOOL)addWhitelistEntry:(NSDictionary *)entity {

    if (privateWhitelist.count == 0) {
        [self decodeWhitelist];
    }
    NSString *publicId = entity[@"publicId"];
    NSUInteger idx = [privateWhitelist indexOfObjectPassingTest:^BOOL(id obj, NSUInteger index, BOOL *stop) {
        NSDictionary *entry = obj;
        return [publicId isEqualToString:entry[@"publicId"]];
    }];
    if (idx == NSNotFound) {
        [privateWhitelist addObject:entity];
        [self encodeWhitelist];
    }
    return idx == NSNotFound;

}

- (void)decodeWhitelist {

    if (config.whitelist != nil) {
        CKGCMCodec *codec = [[CKGCMCodec alloc] initWithData:config.whitelist];
        NSError *error = nil;
        [codec decrypt:_sessionState.contactsKey withAuthData:_sessionState.authData withError:&error];
        if (error == nil) {
            NSInteger count = [codec getInt];
            while (privateWhitelist.count < count) {
                NSMutableDictionary *entity = [NSMutableDictionary dictionary];
                NSString *nickname = [codec getString];
                if (nickname.length > 0) {
                    entity[@"nickname"] = nickname;
                }
                entity[@"publicId"] = [codec getString];
            }
        }
        else {
            NSLog(@"Error decoding whitelist: %@", error.localizedDescription);
        }
    }

}

- (BOOL)deleteWhitelistEntry:(NSString *)publicId {

    if (privateWhitelist.count == 0) {
        [self decodeWhitelist];
    }
    NSUInteger deleteIndex = [privateWhitelist indexOfObjectPassingTest:^BOOL(id obj, NSUInteger index, BOOL *stop) {
        NSDictionary *entity = obj;
        return [publicId isEqualToString:entity[@"publicId"]];
    }];
    if (deleteIndex != NSNotFound) {
        [privateWhitelist removeObjectAtIndex:deleteIndex];
        [self encodeWhitelist];
    }
    return deleteIndex != NSNotFound;

}

- (void)encodeWhitelist {

    RLMRealm *realm = [RLMRealm defaultRealm];
    if (privateWhitelist.count > 0) {
        CKGCMCodec *codec = [[CKGCMCodec alloc] init];
        [codec putInt:privateWhitelist.count];
        for (NSDictionary *entity in privateWhitelist) {
            NSString *nickname = entity[@"nickname"];
            if (nickname == nil) {
                nickname = @"";
            }
            [codec putString:nickname];
            [codec putString:entity[@"publicId"]];
        }
    }
    else {
        [realm beginWriteTransaction];
        config.whitelist = nil;
        [realm commitWriteTransaction];
    }

}

- (NSString*)getContactPolicy {
    return config.contactPolicy;
}

- (NSInteger)getMessageId {

    NSInteger messageId = config.messageId;

    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];
    config.messageId = messageId + 1;
    [realm commitWriteTransaction];

    return messageId;

}

- (NSString*)getNickname {
    return config.nickname;
}

- (void)setContactPolicy:(NSString *)policy {
    
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];
    config.contactPolicy = policy;
    [realm commitWriteTransaction];
    
}

- (void)setNickname:(NSString *)nickname {
    
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];
    config.nickname = nickname;
    [realm commitWriteTransaction];
    
}

@end
