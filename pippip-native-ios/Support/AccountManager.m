//
//  AccountManager.m
//  pippip-native-ios
//
//  Created by Steve Brenneis on 10/9/17.
//  Copyright © 2017 seComm. All rights reserved.
//

#import "AccountManager.h"
#import "AccountConfig.h"
#import <Realm/Realm.h>

static const float CURRENT_VERSION = 1.0;
static NSString *acctName = nil;

@interface AccountManager ()
{
}

@end

@implementation AccountManager

+ (NSString*)accountName {
    return acctName;
}

+ (void)accountName:(NSString*)name {
    acctName = name;
}

+ (BOOL)production {
    return true;
}

- (void)loadAccount {

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docPath = [paths objectAtIndex:0];
    NSString *vaultsPath = [docPath stringByAppendingPathComponent:@"PippipVaults"];
    NSArray *vaultNames = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:vaultsPath
                                                                              error:nil];
    NSMutableArray *accountNames = [vaultNames mutableCopy];
#if TARGET_OS_SIMULATOR
    if (accountNames.count > 0) {
        [accountNames removeObject:@".DS_Store"];
    }
#endif
    if (accountNames.count > 0) {
        acctName = [accountNames firstObject];
        [self loadConfig];
    }

}

- (void)loadConfig {

    [self setRealmConfiguration];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"accountName = %@", acctName];
    RLMResults<AccountConfig*> *configList = [AccountConfig objectsWithPredicate:predicate];
    if (configList.count > 0) {
        // This is where we do version migrations
        AccountConfig *config = [configList firstObject];
        if (config.version < 1.0) {
            RLMRealm *realm = [RLMRealm defaultRealm];
            [realm beginWriteTransaction];
            config.cleartextMessages = NO;
            [realm commitWriteTransaction];
        }
        if (config.version < 1.1) {
            RLMRealm *realm = [RLMRealm defaultRealm];
            [realm beginWriteTransaction];
            config.localAuth = YES;
            config.version = CURRENT_VERSION;
            [realm commitWriteTransaction];
        }
    }

}

- (void)setDefaultConfig {

    [self setRealmConfiguration];
    AccountConfig *config = [[AccountConfig alloc] init];
    config.version = 1.0;
    config.accountName = acctName;
    config.contactPolicy = @"whitelist";
    config.messageId = 1;
    config.contactId = 1;
    config.whitelist = nil;
    config.idMap = nil;
    config.cleartextMessages = NO;

    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];
    [realm addObject:config];
    [realm commitWriteTransaction];

}

- (void)setRealmConfiguration {
    
    RLMRealmConfiguration *config = [RLMRealmConfiguration defaultConfiguration];
    // Use the default directory, but replace the filename with the username
    config.fileURL = [[[config.fileURL URLByDeletingLastPathComponent]
                       URLByAppendingPathComponent:acctName]
                      URLByAppendingPathExtension:@"realm"];
    config.schemaVersion = 9;
    config.migrationBlock = ^(RLMMigration *migration, uint64_t oldSchemaVersion) {
        if (oldSchemaVersion < 9) {
            // No migration necessary
        }
    };
    [RLMRealmConfiguration setDefaultConfiguration:config];
    
}

@end
