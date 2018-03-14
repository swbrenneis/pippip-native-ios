//
//  AddContactViewController.m
//  pippip-native-ios
//
//  Created by Steve Brenneis on 12/12/17.
//  Copyright © 2017 seComm. All rights reserved.
//

#import "AddContactViewController.h"
#import "ContactsTableViewController.h"
#import "ContactManager.h"
#import "ContactDatabase.h"
#import "Configurator.h"
#import "ApplicationSingleton.h"
#import "AlertErrorDelegate.h"

@interface AddContactViewController ()
{
    NSString *action;
    NSString *nickname;
    NSString *publicId;
    NSString *myPublicId;
    NSString *myNickname;
    ContactManager *contactManager;
}

@property (weak, nonatomic) IBOutlet UITextField *nicknameText;
@property (weak, nonatomic) IBOutlet UITextField *publicIdText;

@end

@implementation AddContactViewController

@synthesize errorDelegate;

- (void)viewDidLoad {
    [super viewDidLoad];

    errorDelegate = [[AlertErrorDelegate alloc] initWithViewController:self withTitle:@"Contact Error"];
}

- (void)viewWillAppear:(BOOL)animated {

    ApplicationSingleton *app = [ApplicationSingleton instance];
    myPublicId = app.accountSession.sessionState.publicId;
    contactManager = [[ContactManager alloc] init];
    Configurator *config = [ApplicationSingleton instance].config;
    myNickname = [config getNickname];

    _nicknameText.text = @"";
    _publicIdText.text = @"";
    [_nicknameText becomeFirstResponder];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)addContactComplete:(NSDictionary*)response {

    NSString *result = response[@"result"];
    if ([result isEqualToString:@"pending"]) {
        NSMutableDictionary *addedContact = [NSMutableDictionary dictionary];
        addedContact = [NSMutableDictionary dictionary];
        addedContact[@"publicId"] = response[@"requestedContactId"];
        addedContact[@"status"] = result;
        addedContact[@"timestamp"] = response[@"timestamp"];
        if (nickname != nil && nickname.length > 0) {
            addedContact[@"nickname"] =nickname;
        }
        ContactDatabase *contactDatabase = [[ContactDatabase alloc] init];
        [contactDatabase addContact:addedContact];
        UIAlertController *alert =
        [UIAlertController alertControllerWithTitle:@"Contact Request Added"
                                            message:@"Contact successfully requested"
                                     preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction *action) {
                                                             [self dismissViewControllerAnimated:YES completion:nil];
                                                         }];
        [alert addAction:okAction];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self presentViewController:alert animated:YES completion:nil];
        });
    }
    else {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Contact Request Error"
                                                                       message:@"Invalid server response"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                           style:UIAlertActionStyleDefault
                                                         handler:nil];
        [alert addAction:okAction];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self presentViewController:alert animated:YES completion:nil];
        });
    }

}

- (void)matchNicknameComplete:(NSDictionary*)response {
    
    NSString *result = response[@"result"];
    if ([result isEqualToString:@"matched"]) {
        action = @"RequestContact";
        publicId = response[@"publicId"];
        if (![publicId isEqualToString:myPublicId]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                _publicIdText.text = publicId;
            });
            [contactManager requestContact:publicId];
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self selfContactAlert];
            });
        }
    }
    else {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Invalid Contact ID"
                                                                       message:@"Invalid nickname"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                           style:UIAlertActionStyleDefault
                                                         handler:nil];
        [alert addAction:okAction];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self presentViewController:alert animated:YES completion:nil];
        });
    }
    
}
- (IBAction)cancelClicked:(UIBarButtonItem *)sender {

    [self dismissViewControllerAnimated:YES completion:nil];

}

- (IBAction)saveContact:(UIBarButtonItem *)sender {

    nickname = _nicknameText.text;
    publicId = _publicIdText.text;
    [contactManager setResponseConsumer:self];
    if (nickname.length != 0) {
        action = @"MatchNickname";
        [contactManager matchNickname:nickname];
    }
    else if (publicId.length != 0) {
        if (![publicId isEqualToString:myPublicId]) {
            action = @"RequestContact";
            [contactManager requestContact:publicId];
        }
        else {
            [self selfContactAlert];
        }
    }
    else {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Invalid Contact ID"
                                                                       message:@"Please provide a valid nickname or public ID"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                           style:UIAlertActionStyleDefault
                                                         handler:nil];
        [alert addAction:okAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
    
}

- (void)response:(NSDictionary *)info {

    if ([action isEqualToString:@"MatchNickname"]) {
        [self matchNicknameComplete:info];
    }
    else {
        [self addContactComplete:info];
    }
    
}

- (void)selfContactAlert {

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Invalid Contact ID"
                                                                   message:@"You may not request contact with yourself"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                       style:UIAlertActionStyleDefault
                                                     handler:nil];
    [alert addAction:okAction];
    [self presentViewController:alert animated:YES completion:nil];

}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.

}


@end
