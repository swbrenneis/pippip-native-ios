//
//  AccountManager.m
//  pippip-native-ios
//
//  Created by Steve Brenneis on 10/9/17.
//  Copyright © 2017 seComm. All rights reserved.
//

#import "AccountManager.h"
#import "NSData+HexEncode.h"
#import "CKSHA1.h"

@interface AccountManager ()
{
    NSMutableDictionary *vaultMap;
}

@end

@implementation AccountManager

+ (AccountManager*)loadAccounts {

    AccountManager *manager = [[AccountManager alloc] init];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docPath = [paths objectAtIndex:0];
    NSString *vaultsPath = [docPath stringByAppendingPathComponent:@"PippipVaults"];
    [manager loadFromFile:vaultsPath];
    return manager;
    
}

-(void)addAccount:(NSString *)name {

    CKSHA1 *sha1 = [[CKSHA1 alloc] init];
    NSData *hash = [sha1 digest:[name dataUsingEncoding:NSUTF8StringEncoding]];
    [vaultMap setObject:[hash encodeHexString] forKey:name];
    [self storeAccounts];
    _accountNames = [vaultMap allKeys];

}

- (void)storeAccounts {

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docsDir = paths[0];
    NSString *accountsPath = [NSString stringWithFormat:@"%@/accounts", docsDir];
    [vaultMap writeToFile:accountsPath atomically:YES];

}

- (void)loadFromFile:(NSString*)filePath {

    _accountNames = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:filePath
                                                                        error:nil];

}

- (NSString*)getVaultName:(NSString *)accountName {

    return [vaultMap objectForKey:accountName];

}

@end
