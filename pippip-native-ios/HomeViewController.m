//
//  FirstViewController.m
//  pippip-native-ios
//
//  Created by Steve Brenneis on 10/9/17.
//  Copyright © 2017 seComm. All rights reserved.
//

#import "HomeViewController.h"
#import "AccountManager.h"
#import "NewAccountCreator.h"
#import "Authenticator.h"
#import "CreateAccountDialog.h"

@interface HomeViewController ()
{
    AccountManager *accountManager;

}

@property (weak, nonatomic) IBOutlet UIPickerView *accountPickerView;
@property (weak, nonatomic) IBOutlet UISwitch *defaultAccountSwitch;
@property (weak, nonatomic) IBOutlet UILabel *defaultAccountLabel;
@property (weak, nonatomic) IBOutlet UIButton *authButton;
@property (weak, nonatomic) IBOutlet UIButton *createAccountButton;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    accountManager = [AccountManager loadManager];
    _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    _activityIndicator.hidesWhenStopped = YES;
    [self.view addSubview:_activityIndicator];
    _activityIndicator.center = self.view.center;

    // Connect the picker.
    self.accountPickerView.delegate = self;
    self.accountPickerView.dataSource = self;

    // Enable sign in if there are accounts on this device. Set the status accordingly.
    if (accountManager.accountNames.count == 0) {
        [self.authButton setHidden:YES];
        [self.defaultAccountLabel setHidden:YES];
        [self.defaultAccountSwitch setHidden:YES];
        _defaultMessage = @"Please create a new account";
    }
    else {
        [self.authButton setHidden:NO];
        [self.authButton setEnabled:YES];
        [self.defaultAccountLabel setHidden:NO];
        [self.defaultAccountSwitch setHidden:NO];
        _defaultMessage = @"Sign in or create a new account";
    }
    [self updateStatus:_defaultMessage];

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
    return accountManager.accountNames.count;
}

- (NSAttributedString*)pickerView:(UIPickerView *)pickerView
            attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component {

    NSString *accountName = accountManager.accountNames[row];
    return [[NSAttributedString alloc] initWithString:accountName
                                           attributes:@{NSForegroundColorAttributeName:
                                                            [UIColor colorWithDisplayP3Red:246
                                                                                     green:88
                                                                                      blue:59
                                                                                     alpha:1.0]}];

}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {

    if (row < accountManager.accountNames.count) {
        accountManager.currentAccount = accountManager.accountNames[row];
    }

}

- (IBAction)authClicked:(UIButton *)sender {

    UIAlertController *dialog = [UIAlertController alertControllerWithTitle:@"Authentication"
                                                                    message:accountManager.currentAccount
                                                             preferredStyle:UIAlertControllerStyleAlert];

    [dialog addTextFieldWithConfigurationHandler:^(UITextField* textField) {
        textField.placeholder = @"Passphrase";
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    }];

    UIAlertAction *createAction = [UIAlertAction actionWithTitle:@"Log In"
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction *action) {
                                                             accountManager.currentPassphrase = dialog.textFields[0].text;
                                                             [self authenticate];
                                                         }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                           style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction* action) {
                                                         accountManager.currentPassphrase = nil;
                                                         }];
    
    [dialog addAction:createAction];
    [dialog addAction:cancelAction];
    
    [self presentViewController:dialog animated:YES completion:nil];
    
}

- (void) authenticate {

    [_activityIndicator startAnimating];
    Authenticator *auth = [[Authenticator alloc] initWithViewController:self];
    [auth authenticate:accountManager];
    
}

- (IBAction)createAccountClicked:(UIButton *)sender {

    CreateAccountDialog *dialog = [[CreateAccountDialog alloc] initWithViewController:self
                                                                   withAccountManager:accountManager];
    [dialog present];

}

- (void)createAccount {

    [_activityIndicator startAnimating];
    NewAccountCreator *creator = [[NewAccountCreator alloc] initWithViewController:self];
    [creator createAccount:accountManager];

}

- (void)authenticated:(NSString*)message {

    [self updateActivityIndicator:NO];
    [self updateStatus:message];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.authButton setTitle:@"Sign out" forState:UIControlStateNormal];
        [self.createAccountButton setHidden:YES];
    });

}

- (void)updateStatus:(NSString*)status {

    dispatch_async(dispatch_get_main_queue(), ^{
        [self.statusLabel setText:status];
    });

}

- (void)updateActivityIndicator:(BOOL)start {

    if (start) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.activityIndicator startAnimating];
        });
    }
    else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.activityIndicator stopAnimating];
        });
    }

}

@end
