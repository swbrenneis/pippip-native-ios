//
//  NewAccountCreator.h
//  pippip-native-ios
//
//  Created by Steve Brenneis on 10/10/17.
//  Copyright © 2017 seComm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RequestProcess.h"
#import "HomeViewController.h"
#import "AccountManager.h"

@interface NewAccountCreator : NSObject <RequestProcess>

- (instancetype) initWithViewController:(HomeViewController*)controller;

- (void) createAccount:(AccountManager*)manager;

@end
