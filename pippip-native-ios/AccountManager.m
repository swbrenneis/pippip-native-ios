//
//  AccountManager.m
//  pippip-native-ios
//
//  Created by Steve Brenneis on 10/9/17.
//  Copyright © 2017 seComm. All rights reserved.
//

#import "AccountManager.h"
#import "UserVault.h"
#import "ParameterGenerator.h"
#import "NSData+HexEncode.h"
#import "CKSHA1.h"

@interface AccountManager ()
{
    NSMutableDictionary *vaultMap;
    NSMutableDictionary *config;
}

@end

@implementation AccountManager

+ (AccountManager*)loadManager {

    AccountManager *manager = [[AccountManager alloc] init];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docPath = [paths objectAtIndex:0];
    NSString *vaultsPath = [docPath stringByAppendingPathComponent:@"PippipVaults"];
    [manager loadAccounts:vaultsPath];
    return manager;
    
}

-(void)addAccount:(NSString *)name {

    CKSHA1 *sha1 = [[CKSHA1 alloc] init];
    NSData *hash = [sha1 digest:[name dataUsingEncoding:NSUTF8StringEncoding]];
    [vaultMap setObject:[hash encodeHexString] forKey:name];
    [self storeAccounts];
    _accountNames = [vaultMap allKeys];

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

- (void) generateParameters {
    
    ParameterGenerator *generator = [[ParameterGenerator alloc] init];
    [generator generateParameters:_currentAccount];
    _sessionState = generator;
    
}

- (id)getConfigItem:(NSString *)key {

    return config[key];

}

- (void) loadAccounts:(NSString*)vaultsPath {

    _accountNames = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:vaultsPath
                                                                       error:nil];
    if (_accountNames.count > 0) {
        _currentAccount = _accountNames[0];
    }

}

- (void) loadConfig {

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docPath = [paths objectAtIndex:0];
    NSString *configsPath = [docPath stringByAppendingPathComponent:@"PippipConfig"];
    NSString *plistName = [_currentAccount stringByAppendingString:@".plist"];
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

- (void) loadSessionState:(NSError**)error {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docPath = [paths objectAtIndex:0];
    NSString *vaultsPath = [docPath stringByAppendingPathComponent:@"PippipVaults"];
    NSString *vaultPath = [vaultsPath stringByAppendingPathComponent:_currentAccount];
    NSData *vaultData = [NSData dataWithContentsOfFile:vaultPath];
    
    _sessionState = [[SessionState alloc] init];
    UserVault *vault = [[UserVault alloc] initWithState:_sessionState];
    [vault decode:vaultData withPassword:_currentPassphrase withError:error];
    
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

- (void)storeAccounts {

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docsDir = paths[0];
    NSString *accountsPath = [NSString stringWithFormat:@"%@/accounts", docsDir];
    [vaultMap writeToFile:accountsPath atomically:YES];

}

- (void) storeConfig {

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docPath = [paths objectAtIndex:0];
    NSString *configsPath = [docPath stringByAppendingPathComponent:@"PippipConfig"];
    NSString *plistName = [_currentAccount stringByAppendingString:@".plist"];
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

- (void) storeVault {

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docPath = [paths objectAtIndex:0];
    NSString *vaultsPath = [docPath stringByAppendingPathComponent:@"PippipVaults"];
    NSString *vaultPath = [vaultsPath stringByAppendingPathComponent:_currentAccount];
    
    UserVault *vault = [[UserVault alloc] initWithState:_sessionState];
    NSData *vaultData = [vault encode:_currentPassphrase];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager createDirectoryAtPath:vaultsPath
           withIntermediateDirectories:NO
                            attributes:nil
                                 error:nil];
    [vaultData writeToFile:vaultPath atomically:YES];
    
}

- (NSString*)getVaultName:(NSString *)accountName {

    return [vaultMap objectForKey:accountName];

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
