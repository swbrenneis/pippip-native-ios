//
//  ContactPolicyViewController.m
//  pippip-native-ios
//
//  Created by Steve Brenneis on 12/11/17.
//  Copyright © 2017 seComm. All rights reserved.
//

#import "ContactPolicyViewController.h"
#import "ContactManager.h"
#import "Configurator.h"
#import "AppDelegate.h"

@interface ContactPolicyViewController ()
{
    NSString *selectedPolicy;
    Configurator *config;
}

@property (weak, nonatomic) ContactManager *contactManager;

@property (weak, nonatomic) IBOutlet UISwitch *contactPolicySwitch;

@end

@implementation ContactPolicyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

}

-(void)viewWillAppear:(BOOL)animated {

    AppDelegate *delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    _contactManager = delegate.accountSession.contactManager;
    config = [[Configurator alloc] initWithSessionState:delegate.accountSession.sessionState];
    selectedPolicy = [config getContactPolicy];
    if ([selectedPolicy isEqualToString:@"public"]) {
        [_contactPolicySwitch setOn:YES animated:YES];
    }
    else {
        [_contactPolicySwitch setOn:NO animated:YES];
    }

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)response:(NSDictionary *)info {

    NSString *result = info[@"result"];
    if ([result isEqualToString:@"policySet"]) {
        [config setContactPolicy:selectedPolicy];
        [self performSegueWithIdentifier:@"unwindAfterSave" sender:self];
    }

}
- (IBAction)policyChanged:(UISwitch *)sender {

    if (sender.on) {
        selectedPolicy = @"public";
    }
    else {
        selectedPolicy = @"whitelist";
    }

}

- (IBAction)saveContactPolicy:(UIBarButtonItem *)sender {

    [_contactManager setViewController:self];
    [_contactManager setResponseConsumer:self];
    [_contactManager setContactPolicy:selectedPolicy];

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
