//
//  PublicIdTableViewController.m
//  pippip-native-ios
//
//  Created by Steve Brenneis on 12/10/17.
//  Copyright © 2017 seComm. All rights reserved.
//

#import "PublicIdTableViewController.h"
#import "AppDelegate.h"
#import "AccountManager.h"

@interface PublicIdTableViewController ()

@end

@implementation PublicIdTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Get the account manager
    AppDelegate *delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    AccountManager *accountManager = delegate.accountManager;
    _publicIdCellTitle.text = accountManager.sessionState.publicId;

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
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
