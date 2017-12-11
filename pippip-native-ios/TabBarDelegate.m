//
//  TabBarDelegate.m
//  pippip-native-ios
//
//  Created by Steve Brenneis on 12/9/17.
//  Copyright © 2017 seComm. All rights reserved.
//

#import "TabBarDelegate.h"

@interface TabBarDelegate ()
{

    AccountManager *accountManager;

}
@end

#import "TabBarDelegate.h"

@implementation TabBarDelegate

- (instancetype) initWithAccountManager:(AccountManager *)manager {
    self = [super init];

    accountManager = manager;
    return self;

}

- (BOOL) tabBarController:(UITabBarController *)tabBarController
            shouldSelectViewController:(UIViewController*)viewController {

    if ([viewController.title isEqualToString:@"Home"]) {
        return YES;
    }
    else {
        return accountManager.sessionState.authenticated;
    }

}

@end
