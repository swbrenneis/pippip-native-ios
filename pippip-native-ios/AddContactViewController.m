//
//  AddContactViewController.m
//  pippip-native-ios
//
//  Created by Steve Brenneis on 12/12/17.
//  Copyright © 2017 seComm. All rights reserved.
//

#import "AddContactViewController.h"
#import "ContactsTableViewController.h"
#import "AppDelegate.h"
#import "ContactManager.h"

@interface AddContactViewController ()
{
    NSString *action;
    NSString *nickname;
    NSString *publicId;
}

@property (weak, nonatomic) IBOutlet UITextField *nicknameText;
@property (weak, nonatomic) IBOutlet UITextField *publicIdText;

@property (weak, nonatomic) ContactManager *contactManager;

@end

@implementation AddContactViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Get the contact manager
    AppDelegate *delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    _contactManager = delegate.contactManager;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)addContactComplete:(NSDictionary*)response {

    NSString *result = response[@"result"];
    if ([result isEqualToString:@"pending"]) {
        _addedContact = [NSMutableDictionary dictionaryWithObjectsAndKeys:publicId, @"publicId",
                                                                            @"pending", @"status", nil];
        if (nickname != nil && nickname.length > 0) {
            _addedContact[@"nickname"] =nickname;
        }
        UIAlertController *alert =
        [UIAlertController alertControllerWithTitle:@"Contact Request Added"
                                            message:@"Contact successfully requested"
                                     preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction *action) {
                                                             [self performSegueWithIdentifier:@"requestContactDone" sender:self];
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
        dispatch_async(dispatch_get_main_queue(), ^{
            _publicIdText.text = publicId;
        });
        [_contactManager requestContact:publicId];
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

- (IBAction)requestContact:(id)sender {

    nickname = _nicknameText.text;
    publicId = _publicIdText.text;
    [_contactManager setViewController:self];
    [_contactManager setResponseConsumer:self];
    if (nickname.length != 0) {
        action = @"MatchNickname";
        [_contactManager matchNickname:nickname];
    }
    else if (publicId.length != 0) {
        action = @"RequestContact";
        [_contactManager requestContact:publicId];
    }
    else {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Invalid Contact ID"
                                                                       message:@"Please provide nickname or public ID"
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

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.

}


@end
