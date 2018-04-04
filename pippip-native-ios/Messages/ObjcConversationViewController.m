//
//  ConversationViewController.m
//  pippip-native-ios
//
//  Created by Steve Brenneis on 2/11/18.
//  Copyright © 2018 seComm. All rights reserved.
//

#import "ObjcConversationViewController.h"
#import "ConversationDataSource.h"
#import "Conversation.h"
#import "ApplicationSingleton.h"
#import "MessageManager.h"
#import "ContactManager.h"
#import "AlertErrorDelegate.h"
#import "Authenticator.h"
#import "Notifications.h"

@interface ObjcConversationViewController ()
{
    MessageManager *messageManager;
    ConversationDataSource *dataSource;
    AuthViewController *authView;
    BOOL suspended;
}

@property (weak, nonatomic) IBOutlet UITextField *messageText;
@property (weak, nonatomic) IBOutlet UIStackView *stackView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *stackViewBottom;
@property (weak, nonatomic) IBOutlet UILabel *sendFailedLabel;
@property (weak, nonatomic) IBOutlet UINavigationItem *navItem;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) ConversationCache *conversationCache;

@end

@implementation ObjcConversationViewController

@synthesize errorDelegate;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    dataSource = [[ConversationDataSource alloc] initWithTableView:_tableView withPublicId:_publicId];
    _tableView.dataSource = dataSource;
    [_tableView setDelegate:dataSource];
    [_sendFailedLabel setHidden:YES];
    authView = [self.storyboard instantiateViewControllerWithIdentifier:@"AuthViewController"];

    messageManager = [[MessageManager alloc] init];
    [messageManager setResponseConsumer:self];
    // Public ID is set in the messages table prepare for segue.
    _conversationCache = [ApplicationSingleton instance].conversationCache;

    ContactManager *contactManager = [[ContactManager alloc] init];
    Contact *contact = [contactManager getContact:_publicId];
    if (contact.nickname != nil) {
        _navItem.title = contact.nickname;
    }
    else {
        NSString *fragment = [_publicId substringWithRange:NSMakeRange(0, 6)];
        _navItem.title = [fragment stringByAppendingString:@"..."];
    }
    authView = [self.storyboard instantiateViewControllerWithIdentifier:@"AuthViewController"];
    suspended = NO;

    errorDelegate = [[AlertErrorDelegate alloc] initWithViewController:self withTitle:@"Messages Error"];

    [NSNotificationCenter.defaultCenter addObserver:self
                                           selector:@selector(appResumed:)
                                               name:APP_RESUMED object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self
                                           selector:@selector(appSuspended:)
                                               name:APP_SUSPENDED object:nil];
    

}

- (void)viewDidAppear:(BOOL)animated {

    [[NSNotificationCenter defaultCenter] postNotificationName:@"ConversationLoaded" object:nil];

}

- (void)viewWillAppear:(BOOL)animated {

    NSInteger messageCount = [dataSource getMessageCount];
    if (messageCount > 0) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:messageCount - 1 inSection:0];
        [_tableView scrollToRowAtIndexPath:indexPath
                                      atScrollPosition:UITableViewScrollPositionBottom
                                              animated:YES];
    }

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidHide:)
                                                 name:UIKeyboardDidHideNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:dataSource
                                             selector:@selector(messagesUpdated:)
                                                 name:MESSAGES_UPDATED
                                               object:nil];

}

- (void)viewWillDisappear:(BOOL)animated {

    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:dataSource name:MESSAGES_UPDATED object:nil];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)appResumed:(NSNotification*)notification {
    
    if (suspended) {
        suspended = NO;
        NSDictionary *info = notification.userInfo;
        NSInteger suspendedTime = [info[@"suspendedTime"] integerValue];
        if (suspendedTime > 0 && suspendedTime < 180) {
            [authView setSuspended:YES];
        }
        else {
            Authenticator *auth = [[Authenticator alloc] init];
            [auth logout];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.view.window != nil) {
                [self presentViewController:authView animated:YES completion:nil];
            }
        });
    }
    
}

- (void)appSuspended:(NSNotification*)notification {
    
    suspended = YES;
    
}


- (void)keyboardWillShow:(NSNotification*)notify {

    // get height of visible keyboard
    NSDictionary* keyboardInfo = [notify userInfo];
    NSValue* keyboardFrame = [keyboardInfo valueForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardFrameRect = [keyboardFrame CGRectValue];
    CGFloat keyboardHeight = keyboardFrameRect.size.height;
    _stackViewBottom.constant = keyboardHeight + 2;
    [_stackView setNeedsDisplay];
    Conversation *conversation = [_conversationCache getConversation:_publicId];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[conversation count] - 1 inSection:0];
    [_tableView scrollToRowAtIndexPath:indexPath
                      atScrollPosition:UITableViewScrollPositionBottom
                              animated:YES];

}

- (void)keyboardDidHide:(NSNotification*)notify {

    _stackViewBottom.constant = 5;

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
            [messageManager messageSent:publicId
                           withSequence:[sq integerValue]
                          withTimestamp:[ts integerValue]];

            NSMutableDictionary *messageCount = [NSMutableDictionary dictionary];
            messageCount[@"count"] = [NSNumber numberWithUnsignedInteger:1];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"MessagesUpdated" object:nil userInfo:messageCount];

            dispatch_async(dispatch_get_main_queue(), ^{
                [_sendFailedLabel setHidden:success];
                if (success) {
                    _messageText.text = @"";
                    Conversation *conversation = [_conversationCache getConversation:_publicId];
                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[conversation count] - 1 inSection:0];
                    [_tableView scrollToRowAtIndexPath:indexPath
                                      atScrollPosition:UITableViewScrollPositionBottom
                                              animated:YES];
                }
            });
        }
    }

}

- (IBAction)clearAllMessages:(UIBarButtonItem *)sender {

    [_conversationCache deleteAllMessages:_publicId];
    [dataSource messagesCleared];
    [_tableView reloadData];

}

- (IBAction)sendMessage:(id)sender {

    if (_messageText.text.length > 0) {
        [_sendFailedLabel setHidden:YES];
        NSString *messageText = _messageText.text;
        [messageManager sendMessage:messageText withPublicId:_publicId];
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