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

@interface AccountManager ()
{
}

@end

@implementation AccountManager

- (NSString*)loadAccount {

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
        NSString *accountName = [accountNames firstObject];
        [self loadConfig:accountName];
        return accountName;
    }
    else {
        return @"";
    }

}

- (void)loadConfig:(NSString*)accountName {

    [self setRealmConfiguration:accountName];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"accountName = %@", accountName];
    RLMResults<AccountConfig*> *configList = [AccountConfig objectsWithPredicate:predicate];
    if (configList.count > 0) {
        // This is where we do version migrations
        AccountConfig *config = [configList firstObject];
        if (config.version < 1.0) {
            RLMRealm *realm = [RLMRealm defaultRealm];
            [realm beginWriteTransaction];
            config.version = CURRENT_VERSION;
            config.cleartextMessages = NO;
            [realm commitWriteTransaction];
        }
    }

}

- (void)setDefaultConfig:(NSString*)accountName {

    [self setRealmConfiguration:accountName];
    AccountConfig *config = [[AccountConfig alloc] init];
    config.version = 1.0;
    config.accountName = accountName;
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

- (void)setRealmConfiguration:(NSString*)name {
    
    RLMRealmConfiguration *config = [RLMRealmConfiguration defaultConfiguration];
    // Use the default directory, but replace the filename with the username
    config.fileURL = [[[config.fileURL URLByDeletingLastPathComponent]
                       URLByAppendingPathComponent:name]
                      URLByAppendingPathExtension:@"realm"];
    config.schemaVersion = 6;
    config.migrationBlock = ^(RLMMigration *migration, uint64_t oldSchemaVersion) {
        if (oldSchemaVersion < 6) {
            // No migration necessary
        }
    };
    [RLMRealmConfiguration setDefaultConfiguration:config];
    
}

@end
