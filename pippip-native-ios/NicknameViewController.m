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

@interface NicknameViewController ()
{
    NSString *method;
}

@property (weak, nonatomic) IBOutlet UITextField *nicknameTextField;
@property (weak, nonatomic) IBOutlet UILabel *availableLabel;

@property (weak, nonatomic) ContactManager *contactManager;

@end

@implementation NicknameViewController

-(void)viewDidAppear:(BOOL)animated {

    [_availableLabel setHidden:YES];
    NSString *nickname = [_contactManager currentNickname];
    if (nickname != nil) {
        _nicknameTextField.text = nickname;
    }
    [_contactManager setViewController:self];

}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    // Get the contact manager
    AppDelegate *delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    _contactManager = delegate.contactManager;

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSString*) getNickname {
    return _nicknameTextField.text;
}

- (void)response:(NSDictionary *)info {

    if ([method isEqualToString:@"CheckNickname"]) {
        NSString *result = info[@"result"];
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([result isEqualToString:@"available"]) {
                _availableLabel.text = @"Nickname Is Available";
                [_availableLabel setHidden:NO];
            }
            else if ([result isEqualToString:@"exists"]) {
                _availableLabel.text = @"Nickname Is Not Available";
                [_availableLabel setHidden:NO];
            }
        });
    }
    else {
        
    }

}

- (IBAction)saveNickname:(UIBarButtonItem *)sender {

    method = @"SetNickname";
    [_contactManager setResponseConsumer:self];
    [_contactManager setNickname:_nicknameTextField.text];

}

- (IBAction)checkNickname:(UIButton *)sender {

    method = @"CheckNickname";
    [_availableLabel setHidden:YES];
    [_contactManager setResponseConsumer:self];
    [_contactManager checkNickname:_nicknameTextField.text];

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
