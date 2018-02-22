//
//  ConversationViewController.m
//  pippip-native-ios
//
//  Created by Steve Brenneis on 2/11/18.
//  Copyright © 2018 seComm. All rights reserved.
//

#import "ConversationViewController.h"
#import "ConversationDataSource.h"
#import "ApplicationSingleton.h"
#import "MessageManager.h"
#import "ContactDatabase.h"
#import "AlertErrorDelegate.h"

@interface ConversationViewController ()
{
    MessageManager *messageManager;
    ConversationDataSource *dataSource;
}

@property (weak, nonatomic) IBOutlet UINavigationBar *navBar;
@property (weak, nonatomic) IBOutlet UITextField *messageText;
@property (weak, nonatomic) IBOutlet UITableView *conversationTableView;
@property (weak, nonatomic) IBOutlet UIStackView *stackView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *stackViewBottom;
@property (weak, nonatomic) IBOutlet UILabel *sendFailedLabel;

@property (weak) ConversationCache *conversationCache;

@end

@implementation ConversationViewController

@synthesize errorDelegate;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    dataSource = [[ConversationDataSource alloc] initWithPublicId:_publicId];
    _conversationTableView.dataSource = dataSource;
    [_conversationTableView setDelegate:dataSource];
    [_sendFailedLabel setHidden:YES];

    ApplicationSingleton *app = [ApplicationSingleton instance];
    [app.accountSession setMessageObserver:self];
    messageManager = [[MessageManager alloc] init];
    [messageManager setResponseConsumer:self];
    // Public ID is set in the messages table prepare for segue.
    _conversationCache = app.conversationCache;
    [_conversationCache markMessagesRead:_publicId];

    ContactDatabase *contactDatabase = [[ContactDatabase alloc] init];
    NSDictionary *contact = [contactDatabase getContact:_publicId];
    NSString *nickname = contact[@"nickname"];
    if (nickname != nil) {
        _navBar.topItem.title = nickname;
    }
    else {
        NSString *fragment = [_publicId substringWithRange:NSMakeRange(0, 6)];
        _navBar.topItem.title = [fragment stringByAppendingString:@"..."];
    }

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidHide:)
                                                 name:UIKeyboardDidHideNotification
                                               object:nil];

    errorDelegate = [[AlertErrorDelegate alloc] initWithViewController:self withTitle:@"Messages Error"];
}

- (void)viewWillAppear:(BOOL)animated {

    [_conversationTableView reloadData];
    CGSize contentSize = _conversationTableView.contentSize;
    CGSize viewSize = _conversationTableView.bounds.size;
    //CGSize stackSize = _stackView.frame.size;
    CGPoint newOffset = CGPointMake(0, contentSize.height - viewSize.height);
    [_conversationTableView setContentOffset:newOffset animated:YES];

}

- (void)viewWillDisappear:(BOOL)animated {

    ApplicationSingleton *app = [ApplicationSingleton instance];
    [app.accountSession unsetMessageObserver:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidHideNotification object:nil];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)keyboardWillShow:(NSNotification*)notify {

    // get height of visible keyboard
    NSDictionary* keyboardInfo = [notify userInfo];
    NSValue* keyboardFrame = [keyboardInfo valueForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardFrameRect = [keyboardFrame CGRectValue];
    CGFloat keyboardHeight = keyboardFrameRect.size.height;
    _stackViewBottom.constant = keyboardHeight + 2;
    [_stackView setNeedsDisplay];
    CGSize contentSize = _conversationTableView.contentSize;
    CGSize viewSize = _conversationTableView.bounds.size;
    //CGSize stackSize = _stackView.frame.size;
    CGPoint newOffset = CGPointMake(0, (contentSize.height - viewSize.height) + keyboardHeight);
    [_conversationTableView setContentOffset:newOffset animated:YES];

}

- (void)keyboardDidHide:(NSNotification*)notify {

    _stackViewBottom.constant = 5;

}

- (void)newMessagesReceived {

    [dataSource newMessageAdded];
    [_conversationTableView reloadData];
    CGSize contentSize = _conversationTableView.contentSize;
    CGSize viewSize = _conversationTableView.bounds.size;
    //CGSize stackSize = _stackView.frame.size;
    if (contentSize.height > viewSize.height) {
        CGPoint newOffset = CGPointMake(0, contentSize.height - viewSize.height);
        [_conversationTableView setContentOffset:newOffset animated:YES];
    }

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
            [dataSource newMessageAdded];

            dispatch_async(dispatch_get_main_queue(), ^{
                [_sendFailedLabel setHidden:success];
                if (success) {
                    _messageText.text = @"";
                    [_conversationTableView reloadData];
                    CGSize contentSize = _conversationTableView.contentSize;
                    CGSize viewSize = _conversationTableView.bounds.size;
                    //CGSize stackSize = _stackView.frame.size;
                    CGPoint newOffset = CGPointMake(0, contentSize.height - viewSize.height);
                    [_conversationTableView setContentOffset:newOffset animated:YES];
                }
            });
        }
    }

}

- (IBAction)sendMessage:(id)sender {

    [_sendFailedLabel setHidden:YES];
    NSString *messageText = _messageText.text;
    [messageManager sendMessage:messageText withPublicId:_publicId];

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
