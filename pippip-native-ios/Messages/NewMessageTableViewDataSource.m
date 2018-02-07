//
//  NewMessageTableViewDelegate.m
//  pippip-native-ios
//
//  Created by Steve Brenneis on 2/4/18.
//  Copyright © 2018 seComm. All rights reserved.
//

#import "NewMessageTableViewDataSource.h"
#import "SendToTableViewCell.h"
#import "ContactSearchTableViewCell.h"
#import "ContactSearchDataSource.h"
#import "NewMessageTableViewCell.h"

static const NSInteger CONTACT_SEARCH_SECTION = 1;

@interface NewMessageTableViewDataSource ()
{
    ContactSearchDataSource *contactSource;
    NSInteger hideSectionCount;
}

@property (weak, nonatomic) ContactManager *contactManager;
@property (weak, nonatomic) MessageManager *messageManager;

@end

@implementation NewMessageTableViewDataSource

- (instancetype)initWithManagers:(ContactManager *)contact withMessageManager:(MessageManager *)message {
    self = [super init];

    _contactManager = contact;
    _messageManager = message;
    _cellSource = [[NewMessageCellSource alloc] init];
    contactSource = [[ContactSearchDataSource alloc] init];
    contactSource.rowsInTable = 0;
    contactSource.messageSource = self;
    _selectedNickname = @"";
    _selectedId = @"";

    return self;

}

- (void)contactSelected:(NSString *)publicId withNickname:(NSString *)nickname {

    _selectedId = publicId;
    _selectedNickname = nickname;
    contactSource.rowsInTable = 0;
    [_tableView reloadData];

}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _cellSource.items.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _cellSource.items[section].rowsInItem;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    id<MultiCellItem> item = _cellSource.items[indexPath.section];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:item.cellReuseId];
    item.currentCell = cell;
    
    if ([item.type isEqualToString:@"SendTo"]) {
        SendToTableViewCell *sendTo = (SendToTableViewCell*)cell;
        sendTo.sendToTextView.delegate = self;
        if (_selectedNickname != nil && _selectedNickname.length > 0) {
            sendTo.sendToTextView.text = _selectedNickname;
        }
        else if (_selectedId.length > 0) {
            sendTo.sendToTextView.text = _selectedId;
        }
        else {
            [sendTo.sendToTextView becomeFirstResponder];
        }
    }
    else if ([item.type isEqualToString:@"ContactSearch"]) {
        ContactSearchTableViewCell *search = (ContactSearchTableViewCell*)cell;
        search.contactTableView.dataSource = contactSource;
        [search.contactTableView setDelegate:contactSource];
        [search.contactTableView setHidden:contactSource.rowsInTable == 0];
        contactSource.tableView = search.contactTableView;
    }
    else if ([item.type isEqualToString:@"NewMessage"]) {
        NewMessageTableViewCell *message = (NewMessageTableViewCell*)cell;
        [message.sendFailedLabel setHidden:YES];
    }

    return cell;

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    id<MultiCellItem> item = _cellSource.items[indexPath.section];
    return item.cellHeight;

}

#pragma mark - Text view delegate

- (void)textViewDidChange:(UITextView *)textView {

    NSString *soFar = textView.text;
    if (soFar.length > 0) {
        [contactSource setContactList:[_contactManager searchContacts:soFar]];
    }
    else {
        [contactSource setContactList:nil];
    }
    [_tableView reloadSections:[NSIndexSet indexSetWithIndex:CONTACT_SEARCH_SECTION]
              withRowAnimation:UITableViewRowAnimationNone];

}

@end
