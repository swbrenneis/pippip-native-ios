//
//  Configurator.m
//  pippip-native-ios
//
//  Created by Steve Brenneis on 2/12/18.
//  Copyright © 2018 seComm. All rights reserved.
//

#import "pippip_native_ios-Swift.h"
#import "ConfigDatabase.h"
#import "AccountConfig.h"
#import "AccountManager.h"
#import "CKGCMCodec.h"
#import <Realm/Realm.h>

@interface ConfigDatabase ()
{
    NSMutableArray *_whitelist;
    NSMutableDictionary *keyIndexes;
    SessionState *sessionState;
}

@end

@implementation ConfigDatabase

- (instancetype)init {
    self = [super init];

    _whitelist = [NSMutableArray array];
    //idMap = [NSMutableDictionary dictionary];
    keyIndexes = [NSMutableDictionary dictionary];
    sessionState = [[SessionState alloc] init];

    return self;

}

- (BOOL)addWhitelistEntry:(NSDictionary *)entity {

    AccountConfig *config = [self getConfig];
    if (_whitelist.count == 0) {
        [self decodeWhitelist:config];
    }
    NSString *publicId = entity[@"publicId"];
    NSUInteger idx = [_whitelist indexOfObjectPassingTest:^BOOL(id obj, NSUInteger index, BOOL *stop) {
        NSDictionary *entry = obj;
        return [publicId isEqualToString:entry[@"publicId"]];
    }];
    if (idx == NSNotFound) {
        [_whitelist addObject:entity];
        [self encodeWhitelist:config];
    }
    return idx == NSNotFound;

}

- (void)decodeWhitelist:(AccountConfig*)config {

    if (config.whitelist != nil) {
        CKGCMCodec *codec = [[CKGCMCodec alloc] initWithData:config.whitelist];
        NSError *error = nil;
        [codec decrypt:sessionState.contactsKey withAuthData:sessionState.authData error:&error];
        if (error == nil) {
            NSInteger count = [codec getLong];
            while (_whitelist.count < count) {
                NSMutableDictionary *entity = [NSMutableDictionary dictionary];
                NSString *nickname = [codec getString];
                if (nickname.length > 0) {
                    entity[@"nickname"] = nickname;
                }
                entity[@"publicId"] = [codec getString];
                [_whitelist addObject:entity];
            }
        }
        else {
            NSLog(@"Error decoding whitelist: %@", error.localizedDescription);
        }
    }

}

- (BOOL)deleteWhitelistEntry:(NSString *)publicId {

    AccountConfig *config = [self getConfig];
    if (_whitelist.count == 0) {
        [self decodeWhitelist:config];
    }
    NSUInteger deleteIndex = [_whitelist indexOfObjectPassingTest:^BOOL(id obj, NSUInteger index, BOOL *stop) {
        NSDictionary *entity = obj;
        return [publicId isEqualToString:entity[@"publicId"]];
    }];
    if (deleteIndex != NSNotFound) {
        [_whitelist removeObjectAtIndex:deleteIndex];
        [self encodeWhitelist:config];
    }
    return deleteIndex != NSNotFound;

}

- (void)encodeWhitelist:(AccountConfig*)config {

    RLMRealm *realm = [RLMRealm defaultRealm];
    if (_whitelist.count > 0) {
        CKGCMCodec *codec = [[CKGCMCodec alloc] init];
        [codec putLong:_whitelist.count];
        for (NSDictionary *entity in _whitelist) {
            NSString *nickname = entity[@"nickname"];
            if (nickname == nil) {
                nickname = @"";
            }
            NSString *publicId = entity[@"publicId"];
            [codec putString:nickname];
            [codec putString:publicId];
        }
        NSData *encoded = [codec encrypt:sessionState.contactsKey withAuthData:sessionState.authData];
        if (encoded != nil) {
            [realm beginWriteTransaction];
            config.whitelist = encoded;
            [realm commitWriteTransaction];
        }
        else {
            NSLog(@"Error while encoding whitelist: %@", codec.lastError);
        }
    }
    else {
        [realm beginWriteTransaction];
        config.whitelist = nil;
        [realm commitWriteTransaction];
    }

}

- (AccountConfig*)getConfig {

    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"accountName = %@",
                              [AccountManager accountName]];
    RLMResults<AccountConfig*> *configResults = [AccountConfig objectsWithPredicate:predicate];
    AccountConfig *cfg = [configResults firstObject];
    return cfg;

}

- (NSString*)getContactPolicy {
    AccountConfig *config = [self getConfig];
    return config.contactPolicy;
}

- (NSInteger)getKeyIndex:(NSInteger)contactId {

    NSInteger index = 0;
    NSNumber *ki = keyIndexes[[NSNumber numberWithInteger:contactId]];
    if (ki != nil) {
        index = [ki integerValue] + 1;
        if (index == 10) {
            index = 0;
        }
        keyIndexes[[NSNumber numberWithInteger:contactId]] = [NSNumber numberWithInteger:index];
    }
    else {
        keyIndexes[[NSNumber numberWithInteger:contactId]] = [NSNumber numberWithInteger:1];
    }
    return index;

}

- (NSString*)getNickname {
    AccountConfig *config = [self getConfig];
    NSString *nickname = config.nickname;
    return nickname;
}

- (void)loadWhitelist {

    AccountConfig *config = [self getConfig];
    if (_whitelist.count == 0) {
        [self decodeWhitelist:config];
    }

}

- (NSInteger)newContactId {

    AccountConfig *config = [self getConfig];
    NSInteger contactId = config.contactId;

    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];
    config.contactId = contactId + 1;
    [realm commitWriteTransaction];

    return contactId;

}

- (NSInteger)newMessageId {
    
    AccountConfig *config = [self getConfig];
    NSInteger messageId = config.messageId;
    
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];
    config.messageId = messageId + 1;
    [realm commitWriteTransaction];

    return messageId;
    
}

- (BOOL)storeCleartextMessages {

    AccountConfig *config = [self getConfig];
    return config.cleartextMessages;

}

- (void)storeCleartextMessages:(BOOL)cleartext {
    
    AccountConfig *config = [self getConfig];
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];
    config.cleartextMessages = cleartext;
    [realm commitWriteTransaction];
    
}

- (void)setContactPolicy:(NSString *)policy {
    
    AccountConfig *config = [self getConfig];
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];
    config.contactPolicy = policy;
    [realm commitWriteTransaction];
    
}

- (void)setNickname:(NSString *)nickname {

    AccountConfig *config = [self getConfig];
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];
    config.nickname = nickname;
    [realm commitWriteTransaction];

}

- (BOOL)useLocalAuth {
    
    AccountConfig *config = [self getConfig];
    return config.localAuth;
    
}

- (void)useLocalAuth:(BOOL)localAuth {
    
    AccountConfig *config = [self getConfig];
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];
    config.localAuth = localAuth;
    [realm commitWriteTransaction];
    
}

- (NSInteger)whitelistIndexOf:(NSString *)publicId {

    NSInteger index = 0;
    for (NSDictionary *entry in _whitelist) {
        NSString *entryId = entry[@"publicId"];
        if ([entryId isEqualToString:publicId]) {
            return index;
        }
        index++;
    }
    return NSNotFound;

}

@end
