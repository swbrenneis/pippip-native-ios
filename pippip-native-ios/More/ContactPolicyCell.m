//
//  ContactPolicyCell.m
//  pippip-native-ios
//
//  Created by Steve Brenneis on 2/23/18.
//  Copyright © 2018 seComm. All rights reserved.
//

#import "ContactPolicyCell.h"
#import "AlertErrorDelegate.h"
#import "Configurator.h"
#import "ContactManager.h"
#import "ApplicationSingleton.h"

@interface ContactPolicyCell ()
{
    NSString *selectedPolicy;
    NSString *currentPolicy;
    Configurator *config;
    ContactManager *contactManager;
}

@property (weak, nonatomic) IBOutlet UISwitch *contactPolicySwitch;
@property (weak, nonatomic) MoreTableViewController *moreView;

@end

@implementation ContactPolicyCell

@synthesize errorDelegate;

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code

    contactManager = [[ContactManager alloc] init];
    config = [ApplicationSingleton instance].config;
    currentPolicy = [config getContactPolicy];
    if ([currentPolicy isEqualToString:@"public"]) {
        [_contactPolicySwitch setOn:YES animated:YES];
    }
    else {
        [_contactPolicySwitch setOn:NO animated:YES];
    }

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)response:(NSDictionary *)info {

    if (info != nil) {
        NSString *result = info[@"result"];
        if ([result isEqualToString:@"policySet"]) {
            currentPolicy = selectedPolicy;
            [config setContactPolicy:selectedPolicy];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [_moreView.activityIndicator stopAnimating];
            if ([currentPolicy isEqualToString:@"public"]) {
                [_contactPolicySwitch setOn:YES animated:YES];
            }
            else {
                [_contactPolicySwitch setOn:NO animated:YES];
            }
            [_moreView.tableView reloadData];
        });
    }

}

- (void)setViewController:(MoreTableViewController*)view {

    _moreView = view;
    errorDelegate = [[AlertErrorDelegate alloc] initWithViewController:view withTitle:@"Contact Policy Error"];

}

- (IBAction)policyChanged:(UISwitch *)sender {

    if (sender.on) {
        selectedPolicy = @"public";
    }
    else {
        selectedPolicy = @"whitelist";
    }
    [_moreView.activityIndicator startAnimating];
    [contactManager setResponseConsumer:self];
    [contactManager setContactPolicy:selectedPolicy];

}

@end
