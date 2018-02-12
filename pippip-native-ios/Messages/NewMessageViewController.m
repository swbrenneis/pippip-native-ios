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
#import "NewMessageCellSource.h"
#import "NewMessageTableViewCell.h"
#import "SendToTableViewCell.h"
#import "MultiCellItem.h"

@interface NewMessageViewController ()
{
    NewMessageTableViewDataSource *source;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) MessageManager *messageManager;

@end

@implementation NewMessageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    AppDelegate *delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    _messageManager = delegate.accountSession.messageManager;
    source = [[NewMessageTableViewDataSource alloc] initWithManagers:delegate.accountSession.contactManager
                                                  withMessageManager:_messageManager];
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

- (IBAction)sendMessage:(UIButton *)sender {

    id<MultiCellItem> item = source.cellSource.items[2];
    NewMessageTableViewCell *messageCell = (NewMessageTableViewCell*)item.currentCell;
    [messageCell.sendFailedLabel setHidden:YES];
    NSString *messageText = messageCell.messageTextField.text;
    [_messageManager setViewController:self];
    [_messageManager setResponseConsumer:self];
    [_messageManager sendMessage:messageText withPublicId:source.selectedId];

}

- (void)response:(NSDictionary *)info {

    BOOL success = NO;
    if (info != nil) {
        NSString *result = info[@"result"];
        if ([result isEqualToString:@"sent"]) {
            success = YES;
            NSNumber *sq = info[@"sequence"];
            NSNumber *ts = info[@"timestamp"];
            NSString *publicId = info[@"publicId"];
            [_messageManager messageAcknowledged:publicId
                                    withSequence:[sq integerValue]
                                   withTimestamp:[ts integerValue]];
        }
    }

    dispatch_async(dispatch_get_main_queue(), ^{
        id<MultiCellItem> item = source.cellSource.items[2];
        NewMessageTableViewCell *messageCell = (NewMessageTableViewCell*)item.currentCell;
        [messageCell.sendFailedLabel setHidden:success];
        if (success) {
            [self performSegueWithIdentifier:@"UnwindToMessages" sender:self];
        }
    });

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
