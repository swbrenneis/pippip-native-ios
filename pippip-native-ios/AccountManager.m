//
//  AccountManager.m
//  pippip-native-ios
//
//  Created by Steve Brenneis on 10/9/17.
//  Copyright © 2017 seComm. All rights reserved.
//

#import "AccountManager.h"
//#import "UserVault.h"
#import "ParameterGenerator.h"
#import "NSData+HexEncode.h"
#import "CKSHA1.h"

@interface AccountManager ()
{
    NSMutableDictionary *config;
    NSMutableArray *accountNames;
}

@end

@implementation AccountManager

- (instancetype)initManager {
    self = [super init];

    [self loadAccounts:YES];

    return self;
    
}

- (void)addWhitelistEntry:(NSDictionary *)entity {

    NSMutableArray *whitelist = config[@"whitelist"];
    if (whitelist == nil) {
        whitelist = [NSMutableArray array];
        config[@"whitelist"] = whitelist;
    }
    [whitelist addObject:entity];

}

- (void)deleteWhitelistEntry:(NSDictionary *)entity {

    // Won't be null when this is called.
    NSMutableArray *whitelist = config[@"whitelist"];
    int index = 0;
    NSInteger toRemove = -1;
    NSString *entityId = entity[@"publicId"];
    for (NSDictionary *entry in whitelist) {
        NSString *entryId = entry[@"publicId"];
        if ([entityId isEqualToString:entryId]) {
            toRemove = index;
        }
        index++;
    }
    if (toRemove >= 0) {
        [whitelist removeObjectAtIndex:toRemove];
    }

}

- (id)getConfigItem:(NSString *)key {

    return config[key];

}

- (NSArray*)loadAccounts:(BOOL)setCurrentAccount {

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docPath = [paths objectAtIndex:0];
    NSString *vaultsPath = [docPath stringByAppendingPathComponent:@"PippipVaults"];
    NSArray *vaultNames = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:vaultsPath
                                                                              error:nil];
    accountNames = [vaultNames mutableCopy];
    if (accountNames.count > 0) {
        [accountNames removeObject:@".DS_Store"];
    }
    return accountNames;

}

- (void)loadConfig:(NSString*)accountName {

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docPath = [paths objectAtIndex:0];
    NSString *configsPath = [docPath stringByAppendingPathComponent:@"PippipConfig"];
    NSString *plistName = [accountName stringByAppendingString:@".plist"];
    NSString *configPath = [configsPath stringByAppendingPathComponent:plistName];

    if (![[NSFileManager defaultManager] fileExistsAtPath:configPath]) {
        [self setDefaultConfig];
    }
    else {
        NSData *plistData = [[NSFileManager defaultManager] contentsAtPath:configPath];
        NSError *error = nil;
        config = [NSPropertyListSerialization propertyListWithData:plistData
                                                           options:NSPropertyListMutableContainersAndLeaves
                                                            format:nil
                                                             error:&error];
        if (error != nil) {
            NSLog(@"Error reading properties: %@", [error localizedDescription]);
            [self setDefaultConfig];
        }
    }

}

- (void)setConfigItem:(id)item withKey:(NSString *)key {

    config[key] = item;

}

- (void)setDefaultConfig {
    
    NSString *contactPolicy = @"Friends";
    config = [NSMutableDictionary dictionaryWithObjects:
                    [NSArray arrayWithObjects:contactPolicy, @YES, nil]
                                                forKeys:
                    [NSArray arrayWithObjects:@"contactPolicy", @"loadContacts", nil]];

}

- (void)storeConfig:(NSString*)accountName {

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docPath = [paths objectAtIndex:0];
    NSString *configsPath = [docPath stringByAppendingPathComponent:@"PippipConfig"];
    NSString *plistName = [accountName stringByAppendingString:@".plist"];
    NSString *configPath = [configsPath stringByAppendingPathComponent:plistName];

    NSError *error = nil;
    NSData *configData = [NSPropertyListSerialization dataWithPropertyList:config
                                                                    format:NSPropertyListXMLFormat_v1_0
                                                                   options:0
                                                                     error:&error];
    if (error != nil) {
        NSLog(@"%@", error.localizedDescription);
        NSLog(@"%@", error.localizedFailureReason);
    }
    else {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        [fileManager createDirectoryAtPath:configsPath
               withIntermediateDirectories:NO
                                attributes:nil
                                     error:nil];
        [configData writeToFile:configPath atomically:YES];
    }

}

- (NSInteger)whitelistCount {

    NSArray *whitelist = config[@"whitelist"];
    if (whitelist == nil) {
        return 0;
    }
    else {
        return whitelist.count;
    }

}

- (NSDictionary*)whitelistEntryAtIndex:(NSInteger)index {

    NSArray *whitelist = config[@"whitelist"];
    if (whitelist == nil) {
        return nil;
    }
    else if (index >= whitelist.count) {
        return nil;
    }
    else {
        return whitelist[index];
    }
    
}

@end
