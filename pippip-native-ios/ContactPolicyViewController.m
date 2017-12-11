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

@interface ContactPolicyViewController ()
{
    NSArray *policyNames;
}

@property (weak, nonatomic) AccountManager *accountManager;

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
    
    policyNames = [NSArray arrayWithObjects:@"Public", @"Friends", @"Friends of Friends", nil];
    NSString *currentPolicy = [_accountManager.config objectForKey:@"contactPolicy"];
    int index = 0;
    for (id name in policyNames) {
        NSString *pname = (NSString*)name;
        if ([pname isEqualToString:currentPolicy]) {
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
                                           attributes:@{NSForegroundColorAttributeName:
                                                            [UIColor colorWithDisplayP3Red:246
                                                                                     green:88
                                                                                      blue:59
                                                                                     alpha:1.0]}];

}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    
    if (row < 3) {
        _accountManager.config[@"contactPolicy"] = policyNames[row];
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
