//
//  ErrorDelegateAlertController.h
//  pippip-native-ios
//
//  Created by Steve Brenneis on 10/20/17.
//  Copyright © 2017 seComm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "pippip_native_ios-Swift.h"

@interface AlertErrorDelegate : NSObject <ErrorDelegate>

- (instancetype)initWithViewController:(UIViewController*)viewController withTitle:(NSString*)title;

@end
