//
//  ConversationViewController.m
//  pippip-native-ios
//
//  Created by Steve Brenneis on 2/11/18.
//  Copyright © 2018 seComm. All rights reserved.
//

#import "ConversationViewController.h"
#import "ConversationDataSource.h"
#import "AppDelegate.h"

@interface ConversationViewController ()
{
    ConversationDataSource *dataSource;
}

@property (weak, nonatomic) IBOutlet UITableView *conversationTableView;
@property (weak, nonatomic) IBOutlet UILabel *sendFailedLabel;
@property (weak, nonatomic) IBOutlet UITextField *messageTextField;

@end

@implementation ConversationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    dataSource = [[ConversationDataSource alloc] init];
    _conversationTableView.dataSource = dataSource;
    [_conversationTableView setDelegate:dataSource];
    [_sendFailedLabel setHidden:YES];

}

- (void)viewWillAppear:(BOOL)animated {

    // Message manager set in parent view prepare for segue.
    AppDelegate *delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    dataSource.publicId = _publicId;
    [dataSource setSession:delegate.accountSession.sessionState];
    [_conversationTableView reloadData];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)sendMessage:(id)sender {
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
