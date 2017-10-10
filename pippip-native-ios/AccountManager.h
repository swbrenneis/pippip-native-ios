//
//  AccountManager.h
//  pippip-native-ios
//
//  Created by Steve Brenneis on 10/9/17.
//  Copyright © 2017 seComm. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AccountManager : NSObject

@property (nonatomic, readonly) NSArray *accountNames;

+ (AccountManager*)loadAccounts;

- (void)addAccount:(NSString*)name;

- (NSString*)getVaultName:(NSString*)accountName;

@end
