//
//  FirstViewController.h
//  pippip-native-ios
//
//  Created by Steve Brenneis on 10/9/17.
//  Copyright © 2017 seComm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SessionState.h"

@interface HomeViewController : UIViewController<UIPickerViewDelegate, UIPickerViewDataSource>

@property (nonatomic, readonly) NSString *defaultMessage;
@property (nonatomic) UIActivityIndicatorView *activityIndicator;

- (void)authenticated:(NSString*)message;

- (void) createAccount;

- (void)updateStatus:(NSString*)status;

- (void)updateActivityIndicator:(BOOL)start;

@end

