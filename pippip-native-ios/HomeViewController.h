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

- (void)authenticated:(SessionState*)state;

- (void)updateStatus:(NSString*)status;

@end

