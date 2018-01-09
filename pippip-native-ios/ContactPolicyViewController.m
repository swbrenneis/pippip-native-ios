//
//  ContactPolicyViewController.m
//  pippip-native-ios
//
//  Created by Steve Brenneis on 12/11/17.
//  Copyright © 2017 seComm. All rights reserved.
//

#import "ContactPolicyViewController.h"
#import "AppDelegate.h"
#import "AccountManager.h"
#import "ContactManager.h"

@interface ContactPolicyViewController ()
{
    NSArray *policyNames;
    NSArray *policyValues;
    NSString *selectedPolicy;
}

@property (weak, nonatomic) AccountManager *accountManager;
@property (weak, nonatomic) ContactManager *contactManager;

@property (weak, nonatomic) IBOutlet UIPickerView *policyPickerView;

@end

@implementation ContactPolicyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    _policyPickerView.delegate = self;
    _policyPickerView.dataSource = self;
    
    // Get the account manager
    AppDelegate *delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    _accountManager = delegate.accountManager;
    _contactManager = delegate.contactManager;
    [_contactManager setViewController:self];
    [_contactManager setResponseConsumer:self];

    policyNames = [NSArray arrayWithObjects:@"Public", @"Friends", @"Friends of Friends", nil];
    policyValues = [NSArray arrayWithObjects:@"public", @"whitelist", @"acquaintance", nil];

}

-(void)viewDidAppear:(BOOL)animated {

    NSString *currentPolicy = [_accountManager getConfigItem:@"contactPolicy"];
    int index = 0;
    for (id name in policyValues) {
        NSString *pvalue = (NSString*)name;
        if ([pvalue isEqualToString:currentPolicy]) {
            [_policyPickerView selectRow:index inComponent:0 animated:YES];
        }
        index++;
    }

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// Picker view column count
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView*)pickerView {
    return 1;
}

// Picker view row count.
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return 3;
}

- (NSAttributedString*)pickerView:(UIPickerView *)pickerView
            attributedTitleForRow:(NSInteger)row
                     forComponent:(NSInteger)component {
    
    NSString *policyName = policyNames[row];
    return [[NSAttributedString alloc] initWithString:policyName
                                           attributes:@{NSForegroundColorAttributeName: [UIColor blackColor]}];

}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    
    if (row < 3) {
        selectedPolicy = policyValues[row];
    }
    
}

- (void)response:(NSDictionary *)info {

    NSString *result = info[@"result"];
    if ([result isEqualToString:@"policySet"]) {
        [_accountManager setConfigItem:selectedPolicy withKey:@"contactPolicy"];
        [_accountManager storeConfig];
        [self performSegueWithIdentifier:@"unwindAfterSave" sender:self];
    }

}

- (IBAction)saveContactPolicy:(UIBarButtonItem *)sender {

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
