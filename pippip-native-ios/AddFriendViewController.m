//
//  AddFriendViewController.m
//  pippip-native-ios
//
//  Created by Steve Brenneis on 12/28/17.
//  Copyright © 2017 seComm. All rights reserved.
//

#import "AddFriendViewController.h"
#import "AppDelegate.h"
#import "ContactManager.h"

@interface AddFriendViewController ()
{
    NSString *action;
}

@property (weak, nonatomic) ContactManager *contactManager;

@end

@implementation AddFriendViewController

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

- (void)addFriendComplete:(NSDictionary*)response {

    NSString *result = response[@"result"];
    if ([result isEqualToString:@"added"]) {
        UIAlertController *alert =
            [UIAlertController alertControllerWithTitle:@"Friend Added"
                                                message:@"This friend has been added to your friends list"
                                         preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction *action) {
                                                             [self performSegueWithIdentifier:@"addFriendDone" sender:self];
                                                         }];
        [alert addAction:okAction];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self presentViewController:alert animated:YES completion:nil];
        });
    }
    else if ([result isEqualToString:@"exists"]) {
        UIAlertController *alert =
            [UIAlertController alertControllerWithTitle:@"Friend Not Added"
                                                message:@"This friend is already in your friends list"
                                         preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                           style:UIAlertActionStyleDefault
                                                         handler:nil];
        [alert addAction:okAction];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self presentViewController:alert animated:YES completion:nil];
        });
    }
    else {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Contact Error"
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

- (IBAction)friendAdded:(id)sender {

    NSString *nickname = _nicknameTextField.text;
    NSString *publicId = _publicIdTextField.text;
    [_contactManager setViewController:self];
    [_contactManager setResponseConsumer:self];
    if (nickname.length != 0) {
        action = @"MatchNickname";
        [_contactManager matchNickname:nickname];
    }
    else if (publicId.length != 0) {
        action = @"UpdateWhitelist";
        [_contactManager addFriend:publicId];
    }
    else {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Invalid Friend ID"
                                                                       message:@"Please provide nickname or public ID"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                           style:UIAlertActionStyleDefault
                                                         handler:nil];
        [alert addAction:okAction];
        [self presentViewController:alert animated:YES completion:nil];
    }

}

- (void)matchNicknameComplete:(NSDictionary*)response {

    NSString *result = response[@"result"];
    if ([result isEqualToString:@"matched"]) {
        action = @"UpdateWhitelist";
        NSString *matchedId = response[@"publicId"];
        dispatch_async(dispatch_get_main_queue(), ^{
            _publicIdTextField.text = matchedId;
        });
        [_contactManager addFriend:matchedId];
    }
    else {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Invalid Friend ID"
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

- (void)response:(NSDictionary *)info {

    if ([action isEqualToString:@"MatchNickname"]) {
        [self matchNicknameComplete:info];
    }
    else {
        [self addFriendComplete:info];
    }

}

/*
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
