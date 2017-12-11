//
//  TabBarDelegate.h
//  pippip-native-ios
//
//  Created by Steve Brenneis on 12/9/17.
//  Copyright © 2017 seComm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AccountManager.h"

@interface TabBarDelegate : NSObject<UITabBarControllerDelegate>

- (instancetype) initWithAccountManager:(AccountManager*)manager;

@end
