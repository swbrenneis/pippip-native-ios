//
//  NicknameViewController.m
//  pippip-native-ios
//
//  Created by Steve Brenneis on 12/15/17.
//  Copyright © 2017 seComm. All rights reserved.
//

#import "NicknameViewController.h"
#import "AppDelegate.h"
#import "ContactManager.h"
#import "AccountManager.h"

@interface NicknameViewController ()
{
    NSString *method;
    NSString *currentNickname;
    NSString *pendingNickname;
    NSString *accountName;
}

@property (weak, nonatomic) IBOutlet UITextField *nicknameTextField;
@property (weak, nonatomic) IBOutlet UILabel *availableLabel;

@property (weak, nonatomic) ContactManager *contactManager;
@property (weak, nonatomic) AccountManager *accountManager;

@end

@implementation NicknameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    // Get the contact manager
    AppDelegate *delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    _accountManager = delegate.accountManager;

}

-(void)viewWillAppear:(BOOL)animated {

    AppDelegate *delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    accountName = delegate.accountSession.sessionState.currentAccount;
    _contactManager = delegate.accountSession.contactManager;
    [_availableLabel setHidden:YES];
    currentNickname = [_accountManager getConfigItem:@"nickname"];
    if (currentNickname != nil) {
        _nicknameTextField.text = currentNickname;
    }
    else {
        _nicknameTextField.text = @"";
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)doDeleteNickname {

    method = @"SetNickname";
    pendingNickname = nil;
    [_contactManager setViewController:self];
    [_contactManager setResponseConsumer:self];
    [_contactManager createNickname:nil withOldNickname:currentNickname];
    
}

- (NSString*) getNickname {
    return _nicknameTextField.text;
}

- (void)noNicknameAlert {

    if (currentNickname != nil) {
        _nicknameTextField.text = currentNickname;
    }
    else {
        _nicknameTextField.text = @"";
    }
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Nickname Error"
                                                                   message:@"Please enter a nickname"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                       style:UIAlertActionStyleDefault
                                                     handler:nil];
    [alert addAction:okAction];
    [self presentViewController:alert animated:YES completion:nil];

}

- (void)response:(NSDictionary *)info {

    NSString *result = info[@"result"];
    if ([method isEqualToString:@"MatchNickname"]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([result isEqualToString:@"not matched"]) {
                _availableLabel.text = @"Nickname Is Available";
                [_availableLabel setHidden:NO];
            }
            else if ([result isEqualToString:@"matched"]) {
                _availableLabel.text = @"Nickname Is Not Available";
                [_availableLabel setHidden:NO];
            }
        });
    }
    else {
        [_accountManager setConfigItem:pendingNickname withKey:@"nickname"];
        [_accountManager storeConfig:accountName];
        currentNickname = pendingNickname;
        pendingNickname = nil;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self performSegueWithIdentifier:@"unwindAfterSave" sender:self];
        });
    }

}

- (IBAction)saveNickname:(UIBarButtonItem *)sender {

    if (_nicknameTextField.text != nil && _nicknameTextField.text.length > 0) {
        method = @"SetNickname";
        pendingNickname = _nicknameTextField.text;
        [_contactManager setViewController:self];
        [_contactManager setResponseConsumer:self];
        [_contactManager createNickname:pendingNickname withOldNickname:currentNickname];
    }
    else {
        [self noNicknameAlert];
    }

}

- (IBAction)checkNickname:(UIButton *)sender {

    if (_nicknameTextField.text != nil && _nicknameTextField.text.length > 0) {
        method = @"MatchNickname";
        [_availableLabel setHidden:YES];
        [_contactManager setResponseConsumer:self];
        [_contactManager matchNickname:_nicknameTextField.text];
    }
    else {
        [self noNicknameAlert];
    }

}

- (IBAction)deleteNickname:(UIButton *)sender {

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Delete Nickname"
                                                                   message:@"You are about to delete this nickname. Are you sure?"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *noAction = [UIAlertAction actionWithTitle:@"No"
                                                       style:UIAlertActionStyleCancel
                                                     handler:nil];
    UIAlertAction *yesAction = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDestructive
                                                      handler:^(UIAlertAction *action){
                                                          [self doDeleteNickname];
                                                      }];
    [alert addAction:noAction];
    [alert addAction:yesAction];
    [self presentViewController:alert animated:YES completion:nil];

}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
