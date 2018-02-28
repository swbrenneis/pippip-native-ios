//
//  AuthController.h
//  pippip-native-ios
//
//  Created by Steve Brenneis on 10/9/17.
//  Copyright © 2017 seComm. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AuthViewController : UIViewController<UIPickerViewDelegate, UIPickerViewDataSource>

- (void)authenticated;

//- (void)createAccount:(NSString*)accountName withPassphrase:(NSString*)passphrase;

- (void)updateStatus:(NSString*)status;

- (void)restoreDefaultStatus;

- (void)startActivityIndicator;

- (void)stopActivityIndicator;

@end

