//
//  CreateAccountDialog.m
//  pippip-native-ios
//
//  Created by Steve Brenneis on 12/8/17.
//  Copyright © 2017 seComm. All rights reserved.
//

#import "CreateAccountDialog.h"
#import "NewAccountCreator.h"

@interface CreateAccountDialog ()
{
    UIAlertController *dialog;
    NSString *accountName;
    NSString *passphrase;
    
}

@property (weak, nonatomic) AuthViewController *viewController;

@end

@implementation CreateAccountDialog

-(instancetype) initWithViewController:(AuthViewController*)controller {
    self = [super init];

    _viewController = controller;
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
    [_viewController presentViewController:alert animated:YES completion:nil];

}

- (void)createAccount {

    NewAccountCreator *creator = [[NewAccountCreator alloc] init];
    [creator createAccount:accountName withPassphrase:passphrase];

}

- (void) createSelected {

    accountName = dialog.textFields[0].text;
    passphrase = dialog.textFields[1].text;
    if (accountName == nil || accountName.length == 0) {
        [self accountNameAlert];
    }
    else if (passphrase == nil || passphrase.length == 0){
        [self passphraseAlert];
    }
    else {
        [self createAccount];
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
                                                         [self createAccount];
                                                     }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                           style:UIAlertActionStyleCancel
                                                         handler:nil];
    [alert addAction:okAction];
    [alert addAction:cancelAction];
    [_viewController presentViewController:alert animated:YES completion:nil];

}

- (void) present {

    UIAlertAction *createAction = [UIAlertAction actionWithTitle:@"Create"
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction *action) {
                                                             [self createSelected];
                                                         }];

    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                           style:UIAlertActionStyleCancel
                                                         handler:nil];

    [dialog addAction:createAction];
    [dialog addAction:cancelAction];
    
    [_viewController presentViewController:dialog animated:YES completion:nil];
    
}

@end
