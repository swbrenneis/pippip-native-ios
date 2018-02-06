//
//  NewMessageViewController.m
//  pippip-native-ios
//
//  Created by Steve Brenneis on 2/4/18.
//  Copyright © 2018 seComm. All rights reserved.
//

#import "NewMessageViewController.h"
#import "NewMessageTableViewDataSource.h"
#import "AppDelegate.h"

@interface NewMessageViewController ()
{
    NewMessageTableViewDataSource *source;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation NewMessageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    AppDelegate *delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];

    source = [[NewMessageTableViewDataSource alloc] initWithManagers:delegate.accountSession.contactManager
                                                  withMessageManager:delegate.accountSession.messageManager];
    source.tableView = _tableView;
    [_tableView setDelegate:source];
    _tableView.dataSource = source;

}

- (void)viewWillAppear:(BOOL)animated {

    [_tableView reloadData];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
