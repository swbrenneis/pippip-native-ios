//
//  AccountManager.h
//  pippip-native-ios
//
//  Created by Steve Brenneis on 10/9/17.
//  Copyright © 2017 seComm. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AccountManager : NSObject

- (NSArray*)loadAccounts:(BOOL)setCurrentAccount;

- (void)loadConfig:(NSString*)accountName;

@end
