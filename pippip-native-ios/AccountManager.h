//
//  AccountManager.h
//  pippip-native-ios
//
//  Created by Steve Brenneis on 10/9/17.
//  Copyright © 2017 seComm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SessionState.h"

@interface AccountManager : NSObject

@property (nonatomic) NSArray *accountNames;
@property (nonatomic) NSString *currentAccount;
@property (nonatomic) NSString *currentPassphrase;
@property (nonatomic) SessionState *sessionState;
@property (nonatomic) NSMutableDictionary *config;

+ (AccountManager*)loadManager;

- (void)addAccount:(NSString*)name;

- (void) generateParameters;

- (NSString*)getVaultName:(NSString*)accountName;

- (void) loadConfig;

- (void) loadSessionState:(NSError**)error;

- (void) setDefaultConfig;

- (void) storeConfig;

- (void) storeVault;

@end
