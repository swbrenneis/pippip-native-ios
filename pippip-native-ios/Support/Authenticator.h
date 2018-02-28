//
//  Authenticator.h
//  pippip-native-ios
//
//  Created by Steve Brenneis on 12/1/17.
//  Copyright © 2017 seComm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RequestProcess.h"
#import "AuthViewController.h"
#import "RESTSession.h"

@interface Authenticator : NSObject <RequestProcess>

- (instancetype) initWithViewController:(AuthViewController*)controller;

- (void)authenticate:(NSString*)accountName withPassphrase:(NSString*)passphrase;

- (void)logout;

@end
