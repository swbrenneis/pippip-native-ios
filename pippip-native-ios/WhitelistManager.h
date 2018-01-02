//
//  WhitelistManager.h
//  pippip-native-ios
//
//  Created by Steve Brenneis on 12/28/17.
//  Copyright © 2017 seComm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RequestProcess.h"
#import "AccountManager.h"

@interface WhitelistManager : NSObject <RequestProcess>

- (instancetype) initWithAccountManager:(AccountManager*)manager;

@end
