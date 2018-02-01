//
//  AppDelegate.h
//  pippip-native-ios
//
//  Created by Steve Brenneis on 10/9/17.
//  Copyright © 2017 seComm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AccountManager.h"
#import "AccountSession.h"
#import "RESTSession.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) AccountManager *accountManager;
@property (strong, nonatomic) AccountSession *accountSession;
@property (strong, nonatomic) RESTSession *restSession;

@end

