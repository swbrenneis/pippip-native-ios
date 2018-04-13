//
//  AccountDeleter.m
//  pippip-native-ios
//
//  Created by Steve Brenneis on 4/3/18.
//  Copyright © 2018 seComm. All rights reserved.
//

#import "pippip_native_ios-Swift.h"
#import "AccountDeleter.h"
#import "ApplicationSingleton.h"
#import <Realm/Realm.h>

@implementation AccountDeleter

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
