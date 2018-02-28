//
//  CreateAccountDialog.h
//  pippip-native-ios
//
//  Created by Steve Brenneis on 12/8/17.
//  Copyright © 2017 seComm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AuthViewController.h"

@interface CreateAccountDialog : NSObject

- (instancetype) initWithViewController:(AuthViewController*)controller;

- (void) present;

@end
