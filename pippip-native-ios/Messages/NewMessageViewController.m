//
//  NewMessageViewController.m
//  pippip-native-ios
//
//  Created by Steve Brenneis on 2/4/18.
//  Copyright © 2018 seComm. All rights reserved.
//

#import "NewMessageViewController.h"
#import "ConversationViewController.h"
#import "NewMessageDataSource.h"
#import "ApplicationSingleton.h"
#import "MessageManager.h"
#import "ConversationCache.h"
//#import "ContactManager.h"
#import "AlertErrorDelegate.h"
#import "MBProgressHUD.h"

@interface NewMessageViewController ()
{
    //ContactSearchDataSource *searchSource;
    //ConversationDataSource *convSource;
    MessageManager *messageManager;
    NewMessageDataSource *dataSource;
    //ContactManager *contactManager;
    //NSDictionary *contact;
    //BOOL contactSelected;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *sendFailedLabel;
@property (weak, nonatomic) IBOutlet UITextField *messageText;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *stackViewBottom;
@property (weak, nonatomic) IBOutlet UIStackView *stackView;
@property (weak, nonatomic) IBOutlet UINavigationItem *navItem;
@property (weak, nonatomic) IBOutlet UITextField *searchTextField;
@property (weak, nonatomic) IBOutlet UILabel *toLabel;

@property (weak, nonatomic) ConversationCache *conversationCache;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewTop;

@end

@implementation NewMessageViewController

@synthesize errorDelegate;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    messageManager = [[MessageManager alloc] init];
    [messageManager setResponseConsumer:self];
    _conversationCache = [ApplicationSingleton instance].conversationCache;
    //contactManager = [[ContactManager alloc] init];
    //searchSource = [[ContactSearchDataSource alloc] init];
    dataSource = [[NewMessageDataSource alloc] initWithTableView:_tableView];
    [_tableView setDelegate:dataSource];
    _tableView.dataSource = dataSource;
    [_searchTextField setDelegate:dataSource];
    [_searchTextField becomeFirstResponder];
    [_sendFailedLabel setHidden:YES];

    errorDelegate = [[AlertErrorDelegate alloc] initWithViewController:self withTitle:@"Message Error"];
}

- (void)viewWillAppear:(BOOL)animated {

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidHide:)
                                                 name:UIKeyboardDidHideNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(recipientSelected:)
                                                 name:@"RecipientSelected"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:dataSource
                                             selector:@selector(messagesUpdated:)
                                                 name:@"MessagesUpdated"
                                               object:nil];

}

- (void)viewWillDisappear:(BOOL)animated {

    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"RecipientSelected" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:dataSource name:@"MessagesUpdated" object:nil];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)recipientSelected:(NSNotification*)notification {

    NSDictionary *contact = notification.userInfo;
    NSString *nickname = contact[@"nickname"];
    NSString *publicId = contact[@"publicId"];
    dispatch_async(dispatch_get_main_queue(), ^{
        if (nickname != nil) {
            _searchTextField.text = nickname;
        }
        else {
            _searchTextField.text = publicId;
        }
        [_tableView reloadData];
    });

}

- (IBAction)sendMessage:(UIButton *)sender {

    NSDictionary *contact = [dataSource getSelectedContact];
    if (contact != nil && _messageText.text.length > 0) {
        [_sendFailedLabel setHidden:YES];
        NSString *messageText = _messageText.text;
        [messageManager sendMessage:messageText withPublicId:contact[@"publicId"]];
    }

}

- (void)keyboardWillShow:(NSNotification*)notify {

    // get height of visible keyboard
    NSDictionary* keyboardInfo = [notify userInfo];
    NSValue* keyboardFrame = [keyboardInfo valueForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardFrameRect = [keyboardFrame CGRectValue];
    CGFloat keyboardHeight = keyboardFrameRect.size.height;
    _stackViewBottom.constant = keyboardHeight + 2;
    [_stackView setNeedsDisplay];
    
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
                _searchTextField.alpha = 0.0;
                _toLabel.alpha = 0.0;
                _tableViewTop.constant = 0.0;
                [_sendFailedLabel setHidden:success];
                if (success) {
                    _messageText.text = @"";
                }
            });
        }
    }
    
}

- (IBAction)searchFieldChanged:(UITextField *)sender {

    [dataSource searchFieldChanged:sender.text];

}

- (IBAction)messageStarted:(UITextField *)sender {
/*
    CGRect stackRect = _searchStackView.frame;
    stackRect.size.height = 0;
    [_searchStackView setFrame:stackRect];
//    [_searchStackView setHidden:YES];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.label.text = @"Decrypting messages";
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        convSource = [[ConversationDataSource alloc] initWithTableView:_tableView withPublicId:contact[@"publicId"]];
        dispatch_async(dispatch_get_main_queue(), ^{
            _tableView.dataSource = convSource;
            [_tableView reloadData];
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        });
    });
*/
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
