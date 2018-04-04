//
//  AccountDeleter.m
//  pippip-native-ios
//
//  Created by Steve Brenneis on 4/3/18.
//  Copyright © 2018 seComm. All rights reserved.
//

#import "AccountDeleter.h"
#import "pippip_native_ios-Swift.h"
#import "ApplicationSingleton.h"
#import "UserVault.h"
#import <Realm/Realm.h>

@implementation AccountDeleter

- (BOOL)validatePassphrase:(NSString *)passphrase {

    SessionState *sessionState = [ApplicationSingleton instance].accountSession.sessionState;
    NSString *accountName = sessionState.currentAccount;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docPath = [paths objectAtIndex:0];
    NSString *vaultsPath = [docPath stringByAppendingPathComponent:@"PippipVaults"];
    NSString *vaultPath = [vaultsPath stringByAppendingPathComponent:accountName];
    NSData *vaultData = [NSData dataWithContentsOfFile:vaultPath];
    
    UserVault *vault = [[UserVault alloc] initWithState:sessionState];
    NSError *error = nil;
    [vault decode:vaultData withPassword:passphrase withError:&error];
    return error == nil;

}

- (BOOL)deleteAccount:(NSString *)accountName {
    
    NSFileManager *manager = [NSFileManager defaultManager];
    RLMRealmConfiguration *config = [RLMRealmConfiguration defaultConfiguration];
    NSArray<NSURL *> *realmFileURLs = @[
                                        config.fileURL,
                                        [config.fileURL URLByAppendingPathExtension:@"lock"],
                                        [config.fileURL URLByAppendingPathExtension:@"note"],
                                        [config.fileURL URLByAppendingPathExtension:@"management"]
                                        ];
    for (NSURL *URL in realmFileURLs) {
        NSError *error = nil;
        [manager removeItemAtURL:URL error:&error];
        if (error) {
            // handle error
        }
    }
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docPath = [paths objectAtIndex:0];
    NSString *vaultsPath = [docPath stringByAppendingPathComponent:@"PippipVaults"];
    NSString *vaultPath = [vaultsPath stringByAppendingPathComponent:accountName];
    return [manager removeItemAtPath:vaultPath error:nil];
    
}

@end
