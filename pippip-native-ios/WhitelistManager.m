//
//  WhitelistManager.m
//  pippip-native-ios
//
//  Created by Steve Brenneis on 12/28/17.
//  Copyright © 2017 seComm. All rights reserved.
//

#import "WhitelistManager.h"

@interface WhitelistManager ()

@property (weak, nonatomic) AccountManager *accountManager;

@end

@implementation WhitelistManager

@synthesize errorDelegate;
@synthesize postPacket;

- (instancetype) initWithAccountManager:(AccountManager *)manager {
    self = [super init];

    _accountManager = manager;

    return self;

}

- (void)sessionComplete:(NSDictionary*)response {
    // Nothing to do here.
}

- (void)postComplete:(NSDictionary*)response {
    
}

@end
