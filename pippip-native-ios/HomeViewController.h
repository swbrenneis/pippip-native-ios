//
//  FirstViewController.h
//  pippip-native-ios
//
//  Created by Steve Brenneis on 10/9/17.
//  Copyright © 2017 seComm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SessionState.h"
#import "AccountManager.h"

@interface HomeViewController : UIViewController<UIPickerViewDelegate, UIPickerViewDataSource>

@property (nonatomic, readonly) NSString *defaultMessage;
@property (nonatomic) UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) AccountManager *accountManager;


- (void)authenticated:(NSString*)message;

- (void) createAccount;

- (void)updateStatus:(NSString*)status;

- (void)updateActivityIndicator:(BOOL)start;

@end

