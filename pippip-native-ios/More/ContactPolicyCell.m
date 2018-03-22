//
//  ContactPolicyCell.m
//  pippip-native-ios
//
//  Created by Steve Brenneis on 2/23/18.
//  Copyright © 2018 seComm. All rights reserved.
//

#import "ContactPolicyCell.h"
#import "NotificationErrorDelegate.h"
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

@end

@implementation ContactPolicyCell

@synthesize errorDelegate;

+ (MoreCellItem*)cellItem {

    MoreCellItem *item = [[MoreCellItem alloc] init];
    item.cellReuseId = @"ContactPolicyCell";
    item.cellHeight = 65.0;
    return item;

}

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
    errorDelegate = [[NotificationErrorDelegate alloc] initWithTitle:@"Contact Policy Error"];

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
            if ([currentPolicy isEqualToString:@"public"]) {
                [_contactPolicySwitch setOn:YES animated:YES];
            }
            else {
                [_contactPolicySwitch setOn:NO animated:YES];
            }
        });
        NSMutableDictionary *info = [NSMutableDictionary dictionary];
        info[@"policy"] = currentPolicy;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"PolicyChanged" object:nil userInfo:info];
    }

}
/*
- (void)setViewController:(MoreTableViewController*)view {

    _moreView = view;
    errorDelegate = [[AlertErrorDelegate alloc] initWithViewController:view withTitle:@"Contact Policy Error"];

}
*/
- (IBAction)policyChanged:(UISwitch *)sender {

    if (sender.on) {
        selectedPolicy = @"public";
    }
    else {
        selectedPolicy = @"whitelist";
    }
    [contactManager setResponseConsumer:self];
    [contactManager setContactPolicy:selectedPolicy];

}

@end
