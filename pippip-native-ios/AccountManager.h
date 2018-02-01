//
//  AccountManager.h
//  pippip-native-ios
//
//  Created by Steve Brenneis on 10/9/17.
//  Copyright © 2017 seComm. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AccountManager : NSObject

- (instancetype)initManager;

- (void)addWhitelistEntry:(NSDictionary*)entity;

- (void)deleteWhitelistEntry:(NSDictionary*)entity;

- (id)getConfigItem:(NSString*)key;

- (NSArray*)loadAccounts:(BOOL)setCurrentAccount;

- (void)loadConfig:(NSString*)accountName;

- (void)setConfigItem:(id)item withKey:(NSString*)key;

- (void)setDefaultConfig;

- (void)storeConfig:(NSString*)accountName;

- (NSInteger)whitelistCount;

- (NSDictionary*)whitelistEntryAtIndex:(NSInteger)index;

@end
