//
//  CreateAccountDialog.h
//  pippip-native-ios
//
//  Created by Steve Brenneis on 12/8/17.
//  Copyright © 2017 seComm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HomeViewController.h"

@interface CreateAccountDialog : NSObject

- (instancetype) initWithViewController:(HomeViewController*)controller;

- (void) present;

@end
