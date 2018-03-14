//
//  NewMessageViewController.m
//  pippip-native-ios
//
//  Created by Steve Brenneis on 2/4/18.
//  Copyright © 2018 seComm. All rights reserved.
//

#import "NewMessageViewController.h"
#import "ConversationViewController.h"
#import "ContactSearchDataSource.h"
#import "ConversationDataSource.h"
#import "ApplicationSingleton.h"
#import "MessageManager.h"
#import "ContactManager.h"
#import "AlertErrorDelegate.h"
#import "MBProgressHUD.h"

@interface NewMessageViewController ()
{
    ContactSearchDataSource *searchSource;
    ConversationDataSource *convSource;
    MessageManager *messageManager;
    ContactManager *contactManager;
    NSDictionary *contact;
    BOOL contactSelected;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITextField *searchText;
@property (weak, nonatomic) IBOutlet UILabel *sendFailedLabel;
@property (weak, nonatomic) IBOutlet UITextField *messageText;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *stackViewBottom;
@property (weak, nonatomic) IBOutlet UIStackView *stackView;
@property (weak, nonatomic) IBOutlet UIStackView *searchStackView;
@property (weak, nonatomic) IBOutlet UINavigationItem *navItem;

@end

@implementation NewMessageViewController

@synthesize errorDelegate;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    messageManager = [[MessageManager alloc] init];
    [messageManager setResponseConsumer:self];
    contactManager = [[ContactManager alloc] init];
    searchSource = [[ContactSearchDataSource alloc] init];
    [_tableView setDelegate:self];
    _tableView.dataSource = searchSource;
    [_searchText setDelegate:self];
    [_searchText becomeFirstResponder];
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
                                             selector:@selector(newMessagesReceived:)
                                                 name:@"NewMessagesReceived" object:nil];
    contactSelected = NO;

}
- (void)viewWillDisappear:(BOOL)animated {

    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"NewMessagesReceived" object:nil];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)newMessagesReceived:(NSNotification*)notification {

    [convSource messagesUpdated];
    [self.tableView reloadData];

}

- (IBAction)sendMessage:(UIButton *)sender {

    if (contactSelected && _messageText.text.length > 0) {
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
            [convSource messagesUpdated];

            dispatch_async(dispatch_get_main_queue(), ^{
                [_sendFailedLabel setHidden:success];
                if (success) {
                    _messageText.text = @"";
                    [_tableView reloadData];
                    CGSize contentSize = _tableView.contentSize;
                    CGSize viewSize = _tableView.bounds.size;
                    if (contentSize.height > viewSize.height) {
                        CGPoint newOffset = CGPointMake(0, contentSize.height - viewSize.height);
                        [_tableView setContentOffset:newOffset animated:YES];
                    }
                }
            });
        }
    }
    
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    contact = [searchSource contactAtRow:indexPath.item];
    NSString *nickname = contact[@"nickname"];
    if (nickname != nil) {
        _searchText.text = nickname;
        _navItem.title = nickname;
    }
    else {
        NSString *publicId = contact[@"publicId"];
        _searchText.text = publicId;
        NSString *fragment = [publicId substringWithRange:NSMakeRange(0, 6)];
        _navItem.title = [fragment stringByAppendingString:@"..."];
    }
    [searchSource setContactList:nil];
    CGSize contentSize = _tableView.contentSize;
    CGSize viewSize = _tableView.bounds.size;
    if (contentSize.height > viewSize.height) {
        CGPoint newOffset = CGPointMake(0, contentSize.height - viewSize.height);
        [_tableView setContentOffset:newOffset animated:YES];
    }
    [_stackView setHidden:NO];
    contactSelected = YES;

}

- (IBAction)messageStarted:(UITextField *)sender {

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

}

- (IBAction)searchDidChange:(UITextField *)sender {

    [_stackView setHidden:YES];
    contactSelected = NO;
    NSString *soFar = sender.text;
    if (soFar.length > 0) {
        [searchSource setContactList:[contactManager searchContacts:soFar]];
    }
    else {
        [searchSource setContactList:nil];
    }
    _tableView.dataSource = searchSource;
    [_tableView reloadData];

}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    UIViewController *controller = [segue destinationViewController];
    if ([controller isKindOfClass:[ConversationViewController class]]) {
        ConversationViewController *convController = (ConversationViewController*)controller;
        convController.publicId = contact[@"publicId"];
    }

}

@end
