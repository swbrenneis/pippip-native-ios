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

@interface HomeViewController ()
{
    AccountManager *accountManager;
    NSString *currentAccount;
    NSString *currentPassphrase;

}

@property (weak, nonatomic) IBOutlet UIPickerView *accountPickerView;
@property (weak, nonatomic) IBOutlet UISwitch *defaultAccountSwitch;
@property (weak, nonatomic) IBOutlet UIButton *authButton;
@property (weak, nonatomic) IBOutlet UIButton *createAccountButton;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    accountManager = [AccountManager loadAccounts];

    // Connect the picker.
    self.accountPickerView.delegate = self;
    self.accountPickerView.dataSource = self;

    // Enable sign in if there are accounts on this device. Set the status accordingly.
    if (accountManager.accountNames.count == 0) {
        [self.authButton setEnabled:NO];
        [self updateStatus:@"Please create a new account"];
    }
    else {
        [self.authButton setEnabled:YES];
        [self updateStatus:@"Sign in or create a new account"];
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
        currentAccount = accountManager.accountNames[row];
    }

}

- (IBAction)authClicked:(UIButton *)sender {
}

/*
 * Could this be any uglier?
 * TODO Clean it up.
 */
- (IBAction)createAccountClicked:(UIButton *)sender {

    void (^accountNameAlert)(void) = ^{
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Invalid Account Name"
                                                                       message:@"Empty account names are not permitted"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Ok"
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction *action){}];
        [alert addAction:okAction];
        [self presentViewController:alert animated:YES completion:nil];
    };
    
    void (^passphraseAlert)(void) = ^{
        NSString *message = @"Empty passphrases are not recommended\nTap 'Ok' to continue, 'Cancel' to enter a passphrase";
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Empty Passphrase"
                                                                       message:message
                                                                preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Ok"
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction *action){
                                                             [self createAccount];
                                                         }];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                               style:UIAlertActionStyleCancel
                                                             handler:^(UIAlertAction *action){}];
        [alert addAction:okAction];
        [alert addAction:cancelAction];
        [self presentViewController:alert animated:YES completion:nil];
    };
    
    UIAlertController *dialog = [UIAlertController alertControllerWithTitle:@"Create A New Account"
                                                                    message:@"Enter an account name and passphrase"
                                                             preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *createAction = [UIAlertAction actionWithTitle:@"Create"
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction *action) {
                                                             currentAccount = dialog.textFields[0].text;
                                                             currentPassphrase = dialog.textFields[1].text;
                                                             if (currentAccount == nil || currentAccount.length == 0) {
                                                                 accountNameAlert();
                                                             }
                                                             else if (currentPassphrase == nil ||
                                                                      currentPassphrase.length == 0){
                                                                 passphraseAlert();
                                                             }
                                                             else {
                                                                 [self createAccount];
                                                             }
                                                         }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                           style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction* action) {
                                                             currentAccount = nil;
                                                             currentPassphrase = nil;
                                                         }];
    
    [dialog addTextFieldWithConfigurationHandler:^(UITextField* textField) {
        textField.placeholder = @"Account name";
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    }];
    [dialog addTextFieldWithConfigurationHandler:^(UITextField* textField) {
        textField.placeholder = @"Passphrase";
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    }];
    
    [dialog addAction:createAction];
    [dialog addAction:cancelAction];
    
    [self presentViewController:dialog animated:YES completion:nil];

}

- (void)createAccount {

    NewAccountCreator *creator = [[NewAccountCreator alloc] initWithController:self];
    [creator createAccount:currentAccount withPassphrase:currentPassphrase];

}

- (void)authenticated:(SessionState *)state {

    [_authButton setTitle:@"Sign out" forState:UIControlStateNormal];

}

- (void)updateStatus:(NSString*)status {
    [_statusLabel setText:status];
}

@end
