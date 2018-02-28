//
//  FirstViewController.m
//  pippip-native-ios
//
//  Created by Steve Brenneis on 10/9/17.
//  Copyright © 2017 seComm. All rights reserved.
//

#import "AuthViewController.h"
#import "Authenticator.h"
#import "CreateAccountDialog.h"
#import "ApplicationSingleton.h"
#import "AppDelegate.h"
#import "SessionState.h"
#import "AccountManager.h"
#import "RESTSession.h"

@interface AuthViewController ()
{
    NSArray *accountNames;
    NSString *selectedAccount;
    NSString *passphrase;
    NSString *defaultStatus;
}

@property (weak, nonatomic) IBOutlet UIPickerView *accountPickerView;
@property (weak, nonatomic) IBOutlet UIButton *authButton;
@property (weak, nonatomic) IBOutlet UIButton *createAccountButton;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;

@property (weak, nonatomic) AccountManager *accountManager;
@property (weak, nonatomic) RESTSession *session;
@property (nonatomic) UIActivityIndicatorView *activityIndicator;

@end

@implementation AuthViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    _activityIndicator.hidesWhenStopped = YES;
    [self.view addSubview:_activityIndicator];
    _activityIndicator.center = self.view.center;

    // Get the account manager and REST client
    _accountManager = [ApplicationSingleton instance].accountManager;

    // Connect the picker.
    self.accountPickerView.delegate = self;
    self.accountPickerView.dataSource = self;

}

- (void)viewWillAppear:(BOOL)animated {

    accountNames = [_accountManager loadAccounts:NO];
    // Enable sign in if there are accounts on this device. Set the status accordingly.
    if (accountNames.count == 0) {
        [self.authButton setHidden:YES];
        defaultStatus = @"Please create a new account";
    }
    else {
        selectedAccount = accountNames[0];
        [self.authButton setHidden:NO];
        defaultStatus = @"Sign in or create a new account";
    }
    _statusLabel.text = defaultStatus;

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// Picker view column count
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView*)pickerView {
    return 1;
}

// Picker view row count.
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return accountNames.count;
}

- (NSAttributedString*)pickerView:(UIPickerView *)pickerView
            attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component {

    NSString *accountName = accountNames[row];
    return [[NSAttributedString alloc] initWithString:accountName
                                           attributes:@{NSForegroundColorAttributeName:
                                                            [UIColor colorWithDisplayP3Red:246
                                                                                     green:88
                                                                                      blue:59
                                                                                     alpha:1.0]}];

}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {

    if (row < accountNames.count) {
        selectedAccount = accountNames[row];
    }

}

- (IBAction)authClicked:(UIButton *)sender {

    UIAlertController *dialog = [UIAlertController alertControllerWithTitle:@"Authentication"
                                                                    message:selectedAccount
                                                             preferredStyle:UIAlertControllerStyleAlert];

    [dialog addTextFieldWithConfigurationHandler:^(UITextField* textField) {
        textField.placeholder = @"Passphrase";
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    }];

    UIAlertAction *loginAction = [UIAlertAction actionWithTitle:@"Log In"
                                                          style:UIAlertActionStyleDefault
                                                        handler:^(UIAlertAction *action) {
                                                            passphrase = dialog.textFields[0].text;
                                                            [self authenticate];
                                                        }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                           style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction* action) {
                                                             passphrase = nil;
                                                         }];
    
    [dialog addAction:loginAction];
    [dialog addAction:cancelAction];
    
    [self presentViewController:dialog animated:YES completion:nil];
    
}

- (IBAction)createAccountClicked:(UIButton *)sender {

    CreateAccountDialog *dialog = [[CreateAccountDialog alloc] initWithViewController:self];
    [dialog present];

}

- (void) authenticate {
    
    [_activityIndicator startAnimating];
    [_createAccountButton setHidden:YES];
    Authenticator *auth = [[Authenticator alloc] initWithViewController:self];
    [auth authenticate:selectedAccount withPassphrase:passphrase];
    
}

- (void)authenticated {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self dismissViewControllerAnimated:YES completion:nil];
    });
    
}

- (void)restoreDefaultStatus {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        _statusLabel.text = defaultStatus;
    });
    
}

- (void)startActivityIndicator {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [_activityIndicator startAnimating];
    });
    
}

- (void)stopActivityIndicator {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [_activityIndicator stopAnimating];
    });
    
}

- (void)updateStatus:(NSString*)status {

    dispatch_async(dispatch_get_main_queue(), ^{
        _statusLabel.text = status;
    });

}

@end
