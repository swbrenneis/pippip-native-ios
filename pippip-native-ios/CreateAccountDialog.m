//
//  CreateAccountDialog.m
//  pippip-native-ios
//
//  Created by Steve Brenneis on 12/8/17.
//  Copyright © 2017 seComm. All rights reserved.
//

#import "CreateAccountDialog.h"

@interface CreateAccountDialog ()
{
    AccountManager *accountManager;
    HomeViewController *viewController;
    UIAlertController *dialog;

}
@end

@implementation CreateAccountDialog

-(instancetype) initWithViewController:(HomeViewController*)controller
                      withAccountManager:(AccountManager*)manager {
    self = [super init];
    accountManager = manager;
    viewController = controller;

    dialog = [UIAlertController alertControllerWithTitle:@"Create A New Account"
                                                 message:@"Enter an account name and passphrase"
                                          preferredStyle:UIAlertControllerStyleAlert];
    [dialog addTextFieldWithConfigurationHandler:^(UITextField* textField) {
        textField.placeholder = @"Account name";
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    }];
    [dialog addTextFieldWithConfigurationHandler:^(UITextField* textField) {
        textField.placeholder = @"Passphrase";
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    }];

    return self;

}

- (void) accountNameAlert {

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Invalid Account Name"
                                                                   message:@"Empty account names are not permitted"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Ok"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction *action){}];
    [alert addAction:okAction];
    [viewController presentViewController:alert animated:YES completion:nil];

}

- (void) createSelected {

    accountManager.currentAccount = dialog.textFields[0].text;
    accountManager.currentPassphrase = dialog.textFields[1].text;
    if (accountManager.currentAccount == nil || accountManager.currentAccount.length == 0) {
        [self accountNameAlert];
    }
    else if (accountManager.currentPassphrase == nil || accountManager.currentPassphrase.length == 0){
        [self passphraseAlert];
    }
    else {
        [viewController createAccount];
    }

}

- (void) passphraseAlert {

    NSString *message = @"Empty passphrases are not recommended\nTap 'Ok' to continue, 'Cancel' to start over";
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Empty Passphrase"
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Ok"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction *action){
                                                         [viewController createAccount];
                                                     }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                           style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction *action){}];
    [alert addAction:okAction];
    [alert addAction:cancelAction];
    [viewController presentViewController:alert animated:YES completion:nil];

}

- (void) present {

    UIAlertAction *createAction = [UIAlertAction actionWithTitle:@"Create"
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction *action) {
                                                             [self createSelected];
                                                         }];

    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                           style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction* action) {
                                                             accountManager.currentAccount = nil;
                                                             accountManager.currentPassphrase = nil;
                                                         }];

    [dialog addAction:createAction];
    [dialog addAction:cancelAction];
    
    [viewController presentViewController:dialog animated:YES completion:nil];
    
}

@end
