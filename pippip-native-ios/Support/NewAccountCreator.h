//
//  NewAccountCreator.h
//  pippip-native-ios
//
//  Created by Steve Brenneis on 10/10/17.
//  Copyright © 2017 seComm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RequestProcess.h"
#import "AuthViewController.h"
#import "RESTSession.h"

@interface NewAccountCreator : NSObject <RequestProcess>

- (instancetype) initWithViewController:(AuthViewController*)controller;

- (void) createAccount:(NSString*)accountName withPassphrase:(NSString*)passphrase;

@end
