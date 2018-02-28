//
//  MessagesViewController.m
//  pippip-native-ios
//
//  Created by Steve Brenneis on 2/27/18.
//  Copyright © 2018 seComm. All rights reserved.
//

#import "MessagesViewController.h"
#import "PreviewCell.h"
#import "MessagesHeadingCell.h"
#import "ApplicationSingleton.h"
#import "SessionState.h"
#import "ConversationCache.h"
#import "ConversationViewController.h"
#import "Authenticator.h"

@interface MessagesViewController ()
{
    NSArray *mostRecent;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) SessionState *sessionState;

@property (weak, nonatomic) ConversationCache *conversationCache;

@end

@implementation MessagesViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view.
    mostRecent = [NSArray array];
    _tableView.dataSource = self;
    [_tableView setDelegate:self];
    _sessionState = [ApplicationSingleton instance].accountSession.sessionState;
    _conversationCache = [ApplicationSingleton instance].conversationCache;

    [NSNotificationCenter.defaultCenter addObserver:self
                                           selector:@selector(newSession:)
                                               name:@"NewSession" object:nil];
    
    [NSNotificationCenter.defaultCenter addObserver:self
                                           selector:@selector(newMessagesReceived:)
                                               name:@"NewMessagesReeived" object:nil];
    
}

- (void)viewWillAppear:(BOOL)animated {

    if (_sessionState.authenticated) {
        mostRecent = [_conversationCache mostRecentMessages];
    }
    else {
        mostRecent = [NSArray array];
    }
    [_tableView reloadData];

}

- (void)viewDidAppear:(BOOL)animated {

    if (!_sessionState.authenticated) {
        [self performSegueWithIdentifier:@"AuthModalSegue" sender:nil];
    }

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)signoutClicked:(UIBarButtonItem *)sender {

    Authenticator *auth = [[Authenticator alloc] init];
    [auth logout];
    [self performSegueWithIdentifier:@"AuthModalSegue" sender:nil];

}

#pragma mark - Message handling

- (void)newSession:(NSNotification*)notification {

    _sessionState = (SessionState*)notification.object;

}

- (void)newMessagesReceived:(NSNotification*)notification {

    mostRecent = [_conversationCache mostRecentMessages];
    dispatch_async(dispatch_get_main_queue(), ^{
        [_tableView reloadData];
    });

}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 2;

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    if (section == 0) {
        return 1;
    }
    else {
        return mostRecent.count;
    }

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    if (indexPath.section == 0) {
        UITableViewCell *cell =
            [tableView dequeueReusableCellWithIdentifier:@"MessagesHeadingCell" forIndexPath:indexPath];
        MessagesHeadingCell *headingCell = (MessagesHeadingCell*)cell;
        [headingCell.messageSearchTextField setDelegate:self];
        return cell;
    }
    else {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PreviewCell" forIndexPath:indexPath];
        // Configure the cell...
        PreviewCell *previewCell = (PreviewCell*)cell;
        NSDictionary *message = mostRecent[indexPath.item];
        [previewCell configure:message];
        return cell;
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    if (indexPath.section == 0) {
        return 112.0;
    }
    else {
        return 75.0;
    }

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    if (mostRecent.count > 0 && indexPath.section == 1) {
        
    }

}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    UIViewController * view = [segue destinationViewController];
    if ([view isKindOfClass:[ConversationViewController class]]) {
        ConversationViewController *conversationView = (ConversationViewController*)view;
        NSDictionary *message = mostRecent[self.tableView.indexPathForSelectedRow.item];
        conversationView.publicId = message[@"publicId"];
    }

}

@end
