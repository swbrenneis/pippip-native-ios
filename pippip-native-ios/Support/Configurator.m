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

static NSLock *idLock = nil;

@interface Configurator ()
{
    AccountConfig *config;
    NSMutableArray *privateWhitelist;
    NSMutableDictionary *idMap;
}

@property (weak, nonatomic) SessionState *sessionState;

@end

@implementation Configurator

- (instancetype)initWithSessionState:(SessionState *)state {
    self = [super init];

    if (idLock == nil) {
        idLock = [[NSLock alloc] init];
    }

    _sessionState = state;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"accountName = %@", state.currentAccount];
    RLMResults<AccountConfig*> *configResults = [AccountConfig objectsWithPredicate:predicate];
    config = [configResults firstObject];
    privateWhitelist = [NSMutableArray array];
    _whitelist = privateWhitelist;
    idMap = [NSMutableDictionary dictionary];

    return self;

}

- (void)addContactId:(NSInteger)contactId withPublicId:(NSString *)publicId {

    NSInteger cid = [self getContactId:publicId];
    if (cid == NSNotFound) {
        idMap[publicId] = [NSNumber numberWithInteger:contactId];
        [self encodeIdMap];
    }

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

- (void)decodeIdMap {

    if (config.idMap != nil) {
        CKGCMCodec *codec = [[CKGCMCodec alloc] initWithData:config.whitelist];
        NSError *error = nil;
        [codec decrypt:_sessionState.contactsKey withAuthData:_sessionState.authData withError:&error];
        if (error == nil) {
            NSInteger count = [codec getInt];
            while (idMap.count < count) {
                NSString *publicId = [codec getString];
                idMap[publicId] = [NSNumber numberWithInteger:[codec getInt]];
            }
        }
        else {
            NSLog(@"Error decoding contact ID map: %@", error.localizedDescription);
        }
    }

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

- (void)encodeIdMap {

    RLMRealm *realm = [RLMRealm defaultRealm];
    if (idMap.count > 0) {
        CKGCMCodec *codec = [[CKGCMCodec alloc] init];
        [codec putInt:idMap.count];
        for (NSString* publicId in idMap.allKeys) {
            [codec putString:publicId];
            NSNumber *cid = idMap[publicId];
            [codec putInt:[cid integerValue]];
        }
        NSError *error = nil;
        NSData *encoded = [codec encrypt:_sessionState.contactsKey
                            withAuthData:_sessionState.authData
                               withError:&error];
        if (error == nil) {
            [realm beginWriteTransaction];
            config.idMap = encoded;
            [realm commitWriteTransaction];
        }
        else {
            NSLog(@"Error while encoding contact ID map: %@", error.localizedDescription);
        }
    }
    else {
        [realm beginWriteTransaction];
        config.idMap = nil;
        [realm commitWriteTransaction];
    }
    
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
        NSError *error = nil;
        NSData *encoded = [codec encrypt:_sessionState.contactsKey
                            withAuthData:_sessionState.authData
                               withError:&error];
        if (error == nil) {
            [realm beginWriteTransaction];
            config.whitelist = encoded;
            [realm commitWriteTransaction];
        }
        else {
            NSLog(@"Error while encoding whitelist: %@", error.localizedDescription);
        }
    }
    else {
        [realm beginWriteTransaction];
        config.whitelist = nil;
        [realm commitWriteTransaction];
    }

}

- (NSInteger)getContactId:(NSString *)publicId {

    if (idMap.count == 0) {
        [self decodeIdMap];
    }
    NSNumber *cid = idMap[publicId];
    if (cid != nil) {
        return [cid integerValue];
    }
    else {
        return NSNotFound;
    }

}

- (NSString*)getContactPolicy {
    return config.contactPolicy;
}

- (NSString*)getNickname {
    return config.nickname;
}

- (NSInteger)newContacId {

    [idLock lock];
    NSInteger contactId = config.contactId;
    
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];
    config.contactId = contactId + 1;
    [realm commitWriteTransaction];
    [idLock unlock];
    
    return contactId;
    
}

- (NSInteger)newMessageId {
    
    [idLock lock];
    NSInteger messageId = config.messageId;
    
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];
    config.messageId = messageId + 1;
    [realm commitWriteTransaction];
    [idLock unlock];

    return messageId;
    
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
