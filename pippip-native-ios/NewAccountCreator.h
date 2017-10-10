//
//  NewAccountCreator.h
//  pippip-native-ios
//
//  Created by Steve Brenneis on 10/10/17.
//  Copyright © 2017 seComm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RESTDelegate.h"
#import "HomeViewController.h"

@interface NewAccountCreator : NSObject <RESTDelegate>

- (instancetype) initWithController:(HomeViewController*)controller;

- (void) createAccount:(NSString*)accountName withPassphrase:(NSString*)passphrase;

- (void) restError:(NSString*)error;

- (void) restResponse:(NSDictionary*)response;

@end
