//
//  AccountManager.h
//  pippip-native-ios
//
//  Created by Steve Brenneis on 10/9/17.
//  Copyright © 2017 seComm. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AccountManager : NSObject

+ (NSString*_Nullable)accountName;

+ (void)accountName:(NSString*_Nonnull)name;

+ (BOOL)production;

- (void)loadAccount;

- (void)setDefaultConfig;

@end
