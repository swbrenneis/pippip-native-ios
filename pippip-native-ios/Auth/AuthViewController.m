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
#import "SessionState.h"
#import "AccountManager.h"
#import "NewAccountCreator.h"
#import "RESTSession.h"
#import "TargetConditionals.h"
#import "MBProgressHUD.h"
#import <LocalAuthentication/LAContext.h>

@interface AuthViewController ()
{
    NSString *accountName;
    NSString *passphrase;
    BOOL suspended;
}

@property (weak, nonatomic) IBOutlet UIButton *authButton;
@property (weak, nonatomic) IBOutlet UIButton *createAccountButton;
@property (weak, nonatomic) IBOutlet UILabel *accountNameLabel;
@property (weak, nonatomic) IBOutlet UITextField *accountNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passphraseTextField;

@property (weak, nonatomic) RESTSession *session;

@end

@implementation AuthViewController

- (instancetype)init {
    self = [super init];

    suspended = false;

    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [_passphraseTextField setDelegate:self];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(authenticated:)
                                                 name:@"Authenticated" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateProgress:)
                                                 name:@"UpdateProgress" object:nil];

}

- (void)viewWillAppear:(BOOL)animated {

    accountName = [[ApplicationSingleton instance].accountManager loadAccount];
    
    if (accountName != nil) {
        _accountNameLabel.text = accountName;
        [_accountNameLabel setHidden:NO];
        [_authButton setHidden:suspended];
        [_createAccountButton setHidden:YES];
        [_accountNameTextField setHidden:YES];
    }
    else {
        [_accountNameLabel setHidden:YES];
        [_authButton setHidden:YES];
        [_createAccountButton setHidden:NO];
        [_accountNameTextField setHidden:NO];
    }

    [NSNotificationCenter.defaultCenter addObserver:self
                                           selector:@selector(presentAlert:)
                                               name:@"PresentAlert" object:nil];

}

- (void)viewDidAppear:(BOOL)animated {

    if (suspended) {
        LAContext *laContext = [[LAContext alloc] init];
        NSError *authError = nil;
        if ([laContext canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&authError]) {
            [laContext evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics
                      localizedReason:@"Please provide your thumbprint to open Pippip"
                                reply:^(BOOL success, NSError *error) {
                                    if (success) {
                                        dispatch_async(dispatch_get_main_queue(), ^{
                                            [self dismissViewControllerAnimated:YES completion:nil];
                                        });
                                    }
                                    else {
                                        NSLog(@"Thumbprint authentication failed - %@", error);
                                        Authenticator *auth = [[Authenticator alloc] init];
                                        [auth logout];
                                        dispatch_async(dispatch_get_main_queue(), ^{
                                            [_authButton setHidden:NO];
                                            [_createAccountButton setHidden:NO];
                                        });
                                    }
                                }];
        }
        else {
            NSLog(@"Unable to evaluate thumbprint - %@", authError);
        }
    }

}

- (void)viewWillDisappear:(BOOL)animated {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"PresentAlert" object:nil];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)authClicked:(UIButton *)sender {

    [self doAuthenticate];

}

- (IBAction)createAccountClicked:(UIButton *)sender {

    accountName = _accountNameTextField.text;
    passphrase = _passphraseTextField.text;
    
    if (accountName.length == 0) {
        [self doAccountNameAlert];
    }
    else if (passphrase.length == 0) {
        [self doPassphraseAlert];
    }
    else {
        [self doCreateAccount];
    }

}

- (void)doAuthenticate {

    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeAnnularDeterminate;
    hud.label.text = @"Authenticating...";
    
    NSString *passphrase = _passphraseTextField.text;
    _passphraseTextField.text = @"";
    
#if TARGET_OS_SIMULATOR
    Authenticator *auth = [[Authenticator alloc] init];
    [auth authenticate:accountName withPassphrase:passphrase];
#else
    AccountSession *accountSession = [ApplicationSingleton instance].accountSession;
    if (accountSession.deviceToken != nil) {
        Authenticator *auth = [[Authenticator alloc] init];
        [auth authenticate:accountName withPassphrase:passphrase];
    }
    else {
        UIAlertController *dialog = [UIAlertController alertControllerWithTitle:@"Authentication Error"
                                                                        message:@"Notification token not received"
                                                                 preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                           style:UIAlertActionStyleDefault
                                                         handler:nil];
        
        [dialog addAction:okAction];
        
        [self presentViewController:dialog animated:YES completion:nil];
    }
#endif
    
}

- (void)doCreateAccount {
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeAnnularDeterminate;
    hud.label.text = @"Creating Account...";

    dispatch_async(dispatch_get_main_queue(), ^{
        _accountNameTextField.text = @"";
        _passphraseTextField.text = @"";
        NewAccountCreator *creator = [[NewAccountCreator alloc] init];
        [creator createAccount:accountName withPassphrase:passphrase];
    });

}

- (void)doAccountNameAlert {

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Account Name Error"
                                                                   message:@"Please enter an Account Name"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                       style:UIAlertActionStyleDefault
                                                     handler:nil];
    [alert addAction:okAction];
    [self presentViewController:alert animated:YES completion:nil];

}

- (void)doPassphraseAlert {

    NSString *message = @"Empty passphrases are discouraged.\nTap OK to continue, Cancel to enter a passphrase";
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Empty Passphrase"
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction *action) {
                                                         [self doCreateAccount];
                                                     }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                           style:UIAlertActionStyleCancel
                                                         handler:nil];
    [alert addAction:okAction];
    [alert addAction:cancelAction];
    [self presentViewController:alert animated:YES completion:nil];
    
}

- (void)authenticated:(NSNotification*)notification {

    dispatch_async(dispatch_get_main_queue(), ^{
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [self dismissViewControllerAnimated:YES completion:nil];
    });
    
}

- (void)presentAlert:(NSNotification*)notification {
    
    NSDictionary *info = notification.userInfo;
    UIAlertController *alert = info[@"alert"];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:alert animated:YES completion:nil];
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    });
    
}

- (void)setSuspended:(BOOL)susp {
    suspended = susp;
}

- (void)updateProgress:(NSNotification*)notification {

    dispatch_async(dispatch_get_main_queue(), ^{
        NSDictionary *info = notification.userInfo;
        float progress = [info[@"progress"] floatValue];
        [MBProgressHUD HUDForView:self.view].progress = progress;
    });

}

#pragma - MARK - Text field delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {

    [self doAuthenticate];
    return YES;

}

@end
