//
//  MessagesViewController.m
//  pippip-native-ios
//
//  Created by Steve Brenneis on 2/27/18.
//  Copyright © 2018 seComm. All rights reserved.
//

#import "pippip_native_ios-Swift.h"
#import "MessagesViewController.h"
#import "Notifications.h"
#import "PreviewCell.h"
#import "MessagesHeadingCell.h"
#import "ApplicationSingleton.h"
#import "Authenticator.h"
#import "MBProgressHUD.h"
#import "Chameleon.h"

@interface MessagesViewController ()
{
    NSMutableArray<TextMessage*> *mostRecent;
    AuthViewController *authView;
//    TouchAuth *touchAuth;
//    MessageManager *messageManager;
    ContactManager *contactManager;
    BOOL suspended;
    BOOL accountDeleted;
    SessionState *sessionState;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation MessagesViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view.
    mostRecent = [NSMutableArray array];
    _tableView.dataSource = self;
    [_tableView setDelegate:self];
    authView = [self.storyboard instantiateViewControllerWithIdentifier:@"AuthViewController"];
//    touchAuth = [[TouchAuth alloc] init:self.tableView];
    sessionState = [[SessionState alloc] init];
    suspended = NO;
    accountDeleted = NO;

    [NSNotificationCenter.defaultCenter addObserver:self
                                           selector:@selector(appResumed:)
                                               name:APP_RESUMED object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self
                                           selector:@selector(appSuspended:)
                                               name:APP_SUSPENDED object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self
                                           selector:@selector(newSession:)
                                               name:NEW_SESSION object:nil];

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [NSNotificationCenter.defaultCenter addObserver:self
                                           selector:@selector(newMessages:)
                                               name:NEW_MESSAGES object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self
                                           selector:@selector(presentAlert:)
                                               name:PRESENT_ALERT object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self
                                           selector:@selector(thumbprintComplete:)
                                               name:THUMBPRINT_COMPLETE object:nil];

    if (sessionState.authenticated && !suspended) {
        [self getMostRecentMessages];
        [_tableView reloadData];
    }

}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    [[NSNotificationCenter defaultCenter] removeObserver:self name:NEW_MESSAGES object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PRESENT_ALERT object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:THUMBPRINT_COMPLETE object:nil];

}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    if (accountDeleted) {
        [mostRecent removeAllObjects];
        [self presentViewController:authView animated:YES completion:nil];
        accountDeleted = NO;
    }
    else if (!sessionState.authenticated) {
        [self presentViewController:authView animated:YES completion:nil];
    }

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)composeMessage:(id)sender {

//    ConversationViewController *controller = [[ConversationViewController alloc] init];
//    [self.navigationController pushViewController:controller animated:YES];

}

- (void)getMostRecentMessages {

    [mostRecent removeAllObjects];
    NSArray *contactList = [contactManager getContactList];
    for (Contact *contact in contactList) {
        Conversation *conversation = [ConversationCache getConversation:contact.contactId];
        TextMessage *textMessage = [conversation mostRecentMessage];
        if (textMessage != nil) {
            [mostRecent addObject:textMessage];
        }
    }

}

- (void)appResumed:(NSNotification*)notification {

    if (suspended) {
        suspended = NO;
        NSDictionary *info = notification.userInfo;
        NSInteger suspendedTime = [info[@"suspendedTime"] integerValue];
        if (suspendedTime > 0 && suspendedTime < 1800) {
            authView.suspended = true;
        }
        else {
            authView.suspended = false;
            Authenticator *auth = [[Authenticator alloc] initForLogout];
            [auth logout];
        }
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.view.window != nil) {
            [self presentViewController:self->authView animated:YES completion:nil];
        }
    });

}

- (void)appSuspended:(NSNotification*)notification {

    suspended = YES;
    [mostRecent removeAllObjects];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self->_tableView reloadData];
    });

}

- (void)newSession:(NSNotification*)notification {
    
//    messageManager = [[MessageManager alloc] init];
    // This has to be done here because the default Realm hasn't been set
    // until the user is authenticated
    contactManager = [[ContactManager alloc] init];
    [self getMostRecentMessages];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self->_tableView reloadData];
    });
    
}

- (void)presentAlert:(NSNotification*)notification {

    NSDictionary *info = notification.userInfo;
    NSString *title = info[@"title"];
    NSString *message = info[@"message"];
    dispatch_async(dispatch_get_main_queue(), ^{
        UIColor *alertColor = UIColor.flatSandColor;
        [RKDropdownAlert title:title message: message backgroundColor:alertColor
                     textColor:ContrastColor(alertColor, true) time:2 delegate:nil];
    });
    
}

- (void)thumbprintComplete:(NSNotification*)notification {

    [self getMostRecentMessages];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self->_tableView reloadData];
    });

}

- (IBAction)signoutClicked:(UIBarButtonItem *)sender {

    Authenticator *auth = [[Authenticator alloc] initForLogout];
    [auth logout];
    [authView setSuspended:NO];
    [self presentViewController:authView animated:YES completion:nil];
//    [self performSegueWithIdentifier:@"AuthModalSegue" sender:nil];

}

- (IBAction)unwindAfterAccountDeleted:(UIStoryboardSegue*)segue {

    accountDeleted = YES;

}

- (IBAction)unwindAfterNoContact:(UIStoryboardSegue*)segue {
    
}

#pragma mark - Message handling

- (void)newMessages:(NSNotification*)notification {

    [self getMostRecentMessages];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self->_tableView reloadData];
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
        TextMessage *message = mostRecent[indexPath.item];
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

    if (indexPath.section == 1) {
        NSInteger contactId = mostRecent[indexPath.item].contactId;
        ChattoViewController *viewController = [[ChattoViewController alloc] init];
        viewController.contact = [contactManager getContactById:contactId];
        [self.navigationController pushViewController:viewController animated:YES];
    }

}

#pragma mark - Navigation
/*
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.

}
*/
@end
