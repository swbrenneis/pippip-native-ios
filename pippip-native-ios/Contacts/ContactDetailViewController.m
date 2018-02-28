//
//  ContactDetailViewController.m
//  pippip-native-ios
//
//  Created by Steve Brenneis on 1/22/18.
//  Copyright © 2018 seComm. All rights reserved.
//

#import "ContactDetailViewController.h"
#import "ContactManager.h"
#import "ContactDatabase.h"
#import "AlertErrorDelegate.h"
#import "ApplicationSingleton.h"
#import <time.h>

@interface ContactDetailViewController ()
{
    NSString *action;
    ContactDatabase *contactDatabase;
    ContactManager *contactManager;
}

@property (weak, nonatomic) IBOutlet UITextField *nicknameTextField;
@property (weak, nonatomic) IBOutlet UILabel *publicIdLabel;
@property (weak, nonatomic) IBOutlet UILabel *timestampLabel;
@property (weak, nonatomic) IBOutlet UILabel *nicknameSavedLabel;
@property (weak, nonatomic) IBOutlet UILabel *nicknameNotAvailableLabel;

@end

@implementation ContactDetailViewController

@synthesize errorDelegate;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    errorDelegate = [[AlertErrorDelegate alloc] initWithViewController:self withTitle:@"Contact Error"];
}

- (void)viewWillAppear:(BOOL)animated {

    contactManager = [[ContactManager alloc] init];
    [contactManager setResponseConsumer:self];
    contactDatabase = [[ContactDatabase alloc] init];

    [_nicknameSavedLabel setHidden:YES];
    [_nicknameNotAvailableLabel setHidden:YES];

    NSString *nickname = _contact[@"nickname"];
    if (nickname != nil) {
        _nicknameTextField.text = nickname;
    }
    else {
        _nicknameTextField.text = @"";
    }
    _publicIdLabel.text = _contact[@"publicId"];
    NSNumber *ts = _contact[@"timestamp"];
    NSInteger timestamp = [ts longValue];

    if (timestamp > 0) {
        // Some good old fashioned C
        struct tm *tm_info;
        char buffer[26];
        
        tm_info = localtime(&timestamp);
        strftime(buffer, 26, "%Y-%m-%d %H:%M:%S", tm_info);
        
        _timestampLabel.text = [NSString stringWithUTF8String:buffer];
    }
    else {
        _timestampLabel.text = @"Never";
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)doneClicked:(UIBarButtonItem *)sender {

    [self dismissViewControllerAnimated:YES completion:nil];

}

- (IBAction)getNickname:(id)sender {

    [_nicknameNotAvailableLabel setHidden:YES];
    [_nicknameSavedLabel setHidden:YES];

    action = @"GetNickname";
    [contactManager getNickname:_contact[@"publicId"]];

}

- (IBAction)saveNickname:(id)sender {

    [_nicknameNotAvailableLabel setHidden:YES];
    [_nicknameSavedLabel setHidden:YES];
    
    NSString *nickname = _nicknameTextField.text;
    if (nickname.length > 0) {
        NSMutableDictionary *cont = [contactDatabase getContact:_contact[@"publicId"]];
        cont[@"nickname"] = _nicknameTextField.text;
        [contactDatabase updateContact:cont];
        [_nicknameSavedLabel setHidden:NO];
    }

}

- (IBAction)deleteContact:(id)sender {

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Caution!"
                                                                   message:@"You are about to delete this contact and all associated messages. This action cannot be undone"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction *action) {
                                                         [self doDeleteContact];
                                                     }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                           style:UIAlertActionStyleCancel
                                                         handler:nil];
    [alert addAction:okAction];
    [alert addAction:cancelAction];
    
    [self presentViewController:alert animated:YES completion:nil];

}

- (void)doDeleteContact {

    action = @"DeleteContact";
    [contactManager deleteContact:_contact[@"publicId"]];

}

- (void)deletedAlert {

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Contact Deleted"
                                                                   message:@"This contact has been deleted"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction *action) {
                                                         [self performSegueWithIdentifier:@"UnwindAfterDelete" sender:self];
                                                     }];
    [alert addAction:okAction];
    
    [self presentViewController:alert animated:YES completion:nil];
    
}

- (void)response:(NSDictionary *)info {

    if ([action isEqualToString:@"GetNickname"]) {
        NSString *nickname = info[@"nickname"];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (nickname != nil) {
                _nicknameTextField.text = nickname;
            }
            else {
                [_nicknameNotAvailableLabel setHidden:NO];
            }
        });
    }
    else {
        NSString *result = info[@"result"];
        NSLog(@"Delete result: %@", result);
        [contactDatabase deleteContact:_contact[@"publicId"]];
        ApplicationSingleton *app = [ApplicationSingleton instance];
        [app.conversationCache deleteAllMessages:_contact[@"publicId"]];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self deletedAlert];

        });
    }

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
