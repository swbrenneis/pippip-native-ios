//
//  Authenticator.h
//  pippip-native-ios
//
//  Created by Steve Brenneis on 12/1/17.
//  Copyright © 2017 seComm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RequestProcess.h"
#import "HomeViewController.h"

@interface Authenticator : NSObject <RequestProcess>

- (instancetype) initWithViewController:(HomeViewController*)controller;

- (void) authenticate;

- (void) logout;

@end
