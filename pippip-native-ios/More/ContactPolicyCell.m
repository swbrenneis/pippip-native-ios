//
//  ContactPolicyCell.m
//  pippip-native-ios
//
//  Created by Steve Brenneis on 2/23/18.
//  Copyright © 2018 seComm. All rights reserved.
//

#import "ContactPolicyCell.h"
#import "pippip_native_ios-Swift.h"
#import "Configurator.h"
#import "ContactManager.h"
#import "Notifications.h"
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

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(policyUpdated:)
                                                 name:POLICY_UPDATED
                                               object:nil];

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)policyUpdated:(NSNotification*)notification {

    NSDictionary *info = notification.userInfo;
    if (info != nil) {
        NSString *result = info[@"result"];
        if ([result isEqualToString:@"policySet"]) {
            currentPolicy = selectedPolicy;
            [config setContactPolicy:selectedPolicy];
            NSLog(@"Contact policy set to %@", currentPolicy);
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
        [AsyncNotifier notifyWithName:POLICY_CHANGED object:nil userInfo:info];
    }

}

- (IBAction)policyChanged:(UISwitch *)sender {

    if (sender.on) {
        selectedPolicy = @"public";
    }
    else {
        selectedPolicy = @"whitelist";
    }
    [contactManager setContactPolicy:selectedPolicy];

}

@end
