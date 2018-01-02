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

#pragma mark - Navigation

- (IBAction)friendAdded:(id)sender {

    NSString *nickname = _nicknameTextField.text;
    NSString *publicId = _publicIdTextField.text;
    if (nickname.length != 0) {
        [_contactManager setResponseConsumer:self];
        [_contactManager setViewController:self];
        [_contactManager matchNickname:_nicknameTextField.text];
    }
    else if (publicId.length != 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self performSegueWithIdentifier:@"addFriendDone" sender:self];
        });
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

- (void)response:(NSDictionary *)info {

    NSString *result = info[@"result"];
    if ([result isEqualToString:@"matched"]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            _publicIdTextField.text = info[@"publicId"];
            [self performSegueWithIdentifier:@"addFriendDone" sender:self];
        });
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
/*
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
