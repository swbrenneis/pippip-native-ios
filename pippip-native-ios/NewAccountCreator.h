//
//  NewAccountCreator.h
//  pippip-native-ios
//
//  Created by Steve Brenneis on 10/10/17.
//  Copyright © 2017 seComm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RESTResponseDelegate.h"
#import "SessionDelegate.h"
#import "HomeViewController.h"

@interface NewAccountCreator : NSObject <RESTResponseDelegate, SessionDelegate>

@property (weak, nonatomic) SessionState *sessionState;

- (instancetype) initWithController:(HomeViewController*)controller;

- (void) createAccount:(NSString*)accountName withPassphrase:(NSString*)passphrase;

@end
