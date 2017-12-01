//
//  Authenticator.h
//  pippip-native-ios
//
//  Created by Steve Brenneis on 12/1/17.
//  Copyright © 2017 seComm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RequestProcess.h"
#import "RESTSession.h"
#import "SessionState.h"
#import "HomeViewController.h"
#import "AccountManager.h"

@interface Authenticator : NSObject <RequestProcess>

@property (nonatomic, readonly) RESTSession *session;
@property (nonatomic) SessionState *sessionState;

- (instancetype) initWithViewController:(HomeViewController*)controller;

- (void) authenticate:(AccountManager*)manager;

@end
