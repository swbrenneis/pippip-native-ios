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
#import "SessionState.h"
#import "AccountManager.h"
#import "TabBarDelegate.h"
#import "RESTSession.h"

@interface HomeViewController ()
{
    TabBarDelegate *tabBarDelegate;
    NSArray *accountNames;
    NSString *selectedAccount;
    NSString *passphrase;
}

@property (weak, nonatomic) IBOutlet UIPickerView *accountPickerView;
@property (weak, nonatomic) IBOutlet UIButton *authButton;
@property (weak, nonatomic) IBOutlet UIButton *createAccountButton;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UIButton *signoutButton;

@property (nonatomic) UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) AccountManager *accountManager;
@property (weak, nonatomic) RESTSession *session;

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    _activityIndicator.hidesWhenStopped = YES;
    [self.view addSubview:_activityIndicator];
    _activityIndicator.center = self.view.center;

    // Get the account manager and REST client
    AppDelegate *delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    _accountManager = delegate.accountManager;
    _session = delegate.restSession;

    // Connect the picker.
    self.accountPickerView.delegate = self;
    self.accountPickerView.dataSource = self;

    tabBarDelegate = [[TabBarDelegate alloc] init];
    UITabBarController *tabBar = (UITabBarController*)delegate.window.rootViewController;
    [tabBar setDelegate:tabBarDelegate];

}

- (void)viewWillAppear:(BOOL)animated {

    AppDelegate *delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    accountNames = [_accountManager loadAccounts:NO];
    if (delegate.accountSession == nil || !delegate.accountSession.sessionState.authenticated) {
        // Enable sign in if there are accounts on this device. Set the status accordingly.
        if (accountNames.count == 0) {
            [self.authButton setHidden:YES];
            _defaultMessage = @"Please create a new account";
        }
        else {
            selectedAccount = accountNames[0];
            [self.authButton setHidden:NO];
            _defaultMessage = @"Sign in or create a new account";
        }
        [self.signoutButton setHidden:YES];
        [self updateStatus:_defaultMessage];
    }
    else {
        [self.createAccountButton setHidden:YES];
        [self.authButton setHidden:YES];
        [self.accountPickerView setHidden:YES];
        [self.signoutButton setHidden:NO];
    }

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

- (IBAction)signoutClicked:(UIButton *)sender {

    Authenticator *auth = [[Authenticator alloc] initWithViewController:self withRESTSession:_session];
    [auth logout];
    [_accountManager loadAccounts:NO];
    [_accountPickerView reloadAllComponents];
    [self.createAccountButton setHidden:NO];
    [self.authButton setHidden:NO];
    [self.accountPickerView setHidden:NO];
    [self.signoutButton setHidden:YES];
    [self updateStatus:@"Sign in or create a new account"];

}

- (IBAction)authClicked:(UIButton *)sender {

    UIAlertController *dialog = [UIAlertController alertControllerWithTitle:@"Authentication"
                                                                    message:selectedAccount
                                                             preferredStyle:UIAlertControllerStyleAlert];

    [dialog addTextFieldWithConfigurationHandler:^(UITextField* textField) {
        textField.placeholder = @"Passphrase";
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    }];

    UIAlertAction *createAction = [UIAlertAction actionWithTitle:@"Log In"
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
    
    [dialog addAction:createAction];
    [dialog addAction:cancelAction];
    
    [self presentViewController:dialog animated:YES completion:nil];
    
}

- (void) authenticate {

    [_activityIndicator startAnimating];
    [_createAccountButton setHidden:YES];
    Authenticator *auth = [[Authenticator alloc] initWithViewController:self withRESTSession:_session];
    [auth authenticate:selectedAccount withPassphrase:passphrase];
    
}

- (IBAction)createAccountClicked:(UIButton *)sender {

    CreateAccountDialog *dialog = [[CreateAccountDialog alloc] initWithViewController:self];
    [dialog present];

}

- (void)createAccount:(NSString*)accountName withPassphrase:(NSString *)passphrase {

    [_activityIndicator startAnimating];
    NewAccountCreator *creator = [[NewAccountCreator alloc] initWithViewController:self withRESTSession:_session];
    [creator createAccount:accountName withPassphrase:passphrase];

}

- (void)authenticated:(NSString*)message {

    [self updateActivityIndicator:NO];
    [self updateStatus:message];
    dispatch_async(dispatch_get_main_queue(), ^{
        [_accountManager loadAccounts:NO];
        [_accountPickerView reloadAllComponents];
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
