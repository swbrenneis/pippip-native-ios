//
//  FirstViewController.m
//  pippip-native-ios
//
//  Created by Steve Brenneis on 10/9/17.
//  Copyright © 2017 seComm. All rights reserved.
//

#import "HomeViewController.h"
#import "NewAccountCreator.h"
#import "Authenticator.h"
#import "CreateAccountDialog.h"
#import "AppDelegate.h"
#import "TabBarDelegate.h"

@interface HomeViewController ()
{
    TabBarDelegate *tabBarDelegate;

}

@property (weak, nonatomic) IBOutlet UIPickerView *accountPickerView;
@property (weak, nonatomic) IBOutlet UIButton *authButton;
@property (weak, nonatomic) IBOutlet UIButton *createAccountButton;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UIButton *signoutButton;

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    _activityIndicator.hidesWhenStopped = YES;
    [self.view addSubview:_activityIndicator];
    _activityIndicator.center = self.view.center;

    // Get the account manager
    AppDelegate *delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    _accountManager = delegate.accountManager;

    // Connect the picker.
    self.accountPickerView.delegate = self;
    self.accountPickerView.dataSource = self;

    // Enable sign in if there are accounts on this device. Set the status accordingly.
    if (_accountManager.accountNames.count == 0) {
        [self.authButton setHidden:YES];
        _defaultMessage = @"Please create a new account";
    }
    else {
        [self.authButton setHidden:NO];
        _defaultMessage = @"Sign in or create a new account";
    }
    [self.signoutButton setHidden:YES];
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
    return _accountManager.accountNames.count;
}

- (NSAttributedString*)pickerView:(UIPickerView *)pickerView
            attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component {

    NSString *accountName = _accountManager.accountNames[row];
    return [[NSAttributedString alloc] initWithString:accountName
                                           attributes:@{NSForegroundColorAttributeName:
                                                            [UIColor colorWithDisplayP3Red:246
                                                                                     green:88
                                                                                      blue:59
                                                                                     alpha:1.0]}];

}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {

    if (row < _accountManager.accountNames.count) {
        _accountManager.currentAccount = _accountManager.accountNames[row];
    }

}

- (IBAction)signoutClicked:(UIButton *)sender {

    [_accountManager storeConfig];
    Authenticator *auth = [[Authenticator alloc] initWithViewController:self];
    [auth logout:_accountManager];
    _accountManager.sessionState.authenticated = NO;
    [self.createAccountButton setHidden:NO];
    [self.authButton setHidden:NO];
    [self.accountPickerView setHidden:NO];
    [self.signoutButton setHidden:YES];
    [self updateStatus:@"Sign in or create a new account"];

}

- (IBAction)authClicked:(UIButton *)sender {

    UIAlertController *dialog = [UIAlertController alertControllerWithTitle:@"Authentication"
                                                                    message:_accountManager.currentAccount
                                                             preferredStyle:UIAlertControllerStyleAlert];

    [dialog addTextFieldWithConfigurationHandler:^(UITextField* textField) {
        textField.placeholder = @"Passphrase";
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    }];

    UIAlertAction *createAction = [UIAlertAction actionWithTitle:@"Log In"
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction *action) {
                                                             _accountManager.currentPassphrase = dialog.textFields[0].text;
                                                             [self authenticate];
                                                         }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                           style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction* action) {
                                                         _accountManager.currentPassphrase = nil;
                                                         }];
    
    [dialog addAction:createAction];
    [dialog addAction:cancelAction];
    
    [self presentViewController:dialog animated:YES completion:nil];
    
}

- (void) authenticate {

    [_activityIndicator startAnimating];
    Authenticator *auth = [[Authenticator alloc] initWithViewController:self];
    [auth authenticate:_accountManager];
    
}

- (IBAction)createAccountClicked:(UIButton *)sender {

    CreateAccountDialog *dialog = [[CreateAccountDialog alloc] initWithViewController:self
                                                                   withAccountManager:_accountManager];
    [dialog present];

}

- (void)createAccount {

    [_activityIndicator startAnimating];
    NewAccountCreator *creator = [[NewAccountCreator alloc] initWithViewController:self];
    [creator createAccount:_accountManager];

}

- (void)authenticated:(NSString*)message {

    [self updateActivityIndicator:NO];
    [self updateStatus:message];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.createAccountButton setHidden:YES];
        [self.authButton setHidden:YES];
        [self.accountPickerView setHidden:YES];
        [self.signoutButton setHidden:NO];
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
