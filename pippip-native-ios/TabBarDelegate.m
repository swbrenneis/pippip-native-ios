//
//  TabBarDelegate.m
//  pippip-native-ios
//
//  Created by Steve Brenneis on 12/9/17.
//  Copyright © 2017 seComm. All rights reserved.
//

#import "TabBarDelegate.h"
#import "AppDelegate.h"
#import "AccountSession.h"

@interface TabBarDelegate ()
{
}

@end

#import "TabBarDelegate.h"

@implementation TabBarDelegate

- (BOOL) tabBarController:(UITabBarController *)tabBarController
            shouldSelectViewController:(UIViewController*)viewController {

    AppDelegate *delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    if ([viewController.title isEqualToString:@"Home"]) {
        return YES;
    }
    else {
        return delegate.accountSession.sessionState.authenticated;
    }

}

@end
