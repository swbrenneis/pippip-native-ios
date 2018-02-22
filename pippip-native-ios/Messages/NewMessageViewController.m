//
//  NewMessageViewController.m
//  pippip-native-ios
//
//  Created by Steve Brenneis on 2/4/18.
//  Copyright © 2018 seComm. All rights reserved.
//

#import "NewMessageViewController.h"
#import "ContactSearchDataSource.h"
#import "ConversationDataSource.h"
#import "ApplicationSingleton.h"
#import "MessageManager.h"
#import "ContactManager.h"
#import "AlertErrorDelegate.h"

@interface NewMessageViewController ()
{
    ContactSearchDataSource *searchSource;
    ConversationDataSource *convSource;
    MessageManager *messageManager;
    ContactManager *contactManager;
    NSDictionary *contact;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITextView *searchText;
@property (weak, nonatomic) IBOutlet UILabel *sendFailedLabel;
@property (weak, nonatomic) IBOutlet UITextField *messageText;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *stackViewBottom;
@property (weak, nonatomic) IBOutlet UIStackView *stackView;


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
    convSource = [[ConversationDataSource alloc] init];
    [_tableView setDelegate:self];
    _tableView.dataSource = searchSource;
    [_searchText setDelegate:self];
    [_searchText becomeFirstResponder];
    [_sendFailedLabel setHidden:YES];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidHide:)
                                                 name:UIKeyboardDidHideNotification
                                               object:nil];

    errorDelegate = [[AlertErrorDelegate alloc] initWithViewController:self withTitle:@"Message Error"];
}

- (void)viewWillDisappear:(BOOL)animated {

    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidHideNotification object:nil];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)newMessagesReceived {

    [convSource newMessageAdded];
    [self.tableView reloadData];

}

- (IBAction)sendMessage:(UIButton *)sender {

    [_sendFailedLabel setHidden:YES];
    NSString *messageText = _messageText.text;
    [messageManager sendMessage:messageText withPublicId:contact[@"publicId"]];

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
            [convSource newMessageAdded];
            
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
    }
    else {
        _searchText.text = contact[@"publicId"];
    }
    [searchSource setContactList:nil];
    convSource = [[ConversationDataSource alloc] initWithPublicId:contact[@"publicId"]];
    _tableView.dataSource = convSource;
    [_tableView reloadData];
    CGSize contentSize = _tableView.contentSize;
    CGSize viewSize = _tableView.bounds.size;
    if (contentSize.height > viewSize.height) {
        CGPoint newOffset = CGPointMake(0, contentSize.height - viewSize.height);
        [_tableView setContentOffset:newOffset animated:YES];
    }

    ApplicationSingleton *app = [ApplicationSingleton instance];
    [app.accountSession setMessageObserver:self];

}

#pragma mark - Text view delegate

- (void)textViewDidChange:(UITextView *)textView {
    
    NSString *soFar = textView.text;
    if (soFar.length > 0) {
        [searchSource setContactList:[contactManager searchContacts:soFar]];
    }
    else {
        [searchSource setContactList:nil];
    }
    _tableView.dataSource = searchSource;
    [_tableView reloadData];
    
    ApplicationSingleton *app = [ApplicationSingleton instance];
    [app.accountSession unsetMessageObserver:self];
    
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
