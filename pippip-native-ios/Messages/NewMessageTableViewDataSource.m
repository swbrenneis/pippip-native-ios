//
//  NewMessageTableViewDelegate.m
//  pippip-native-ios
//
//  Created by Steve Brenneis on 2/4/18.
//  Copyright © 2018 seComm. All rights reserved.
//

#import "NewMessageTableViewDataSource.h"
#import "NewMessageCellSource.h"
#import "SendToTableViewCell.h"
#import "ContactSearchTableViewCell.h"
#import "ContactSearchDataSource.h"

static const NSInteger CONTACT_SEARCH_SECTION = 1;

@interface NewMessageTableViewDataSource ()
{
    NewMessageCellSource *source;
    ContactSearchDataSource *contactSource;
    NSString *selectedId;
    NSString *selectedNickname;
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
    source = [[NewMessageCellSource alloc] init];
    contactSource = [[ContactSearchDataSource alloc] init];
    contactSource.rowsInTable = 0;
    contactSource.messageSource = self;
    selectedNickname = @"";
    selectedId = @"";

    return self;

}

- (void)contactSelected:(NSString *)publicId withNickname:(NSString *)nickname {

    selectedId = publicId;
    selectedNickname = nickname;
    contactSource.rowsInTable = 0;
    [_tableView reloadData];

}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return source.items.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return source.items[section].rowsInItem;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    id<MultiCellItem> item = source.items[indexPath.section];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:item.cellReuseId];
    
    if ([item.type isEqualToString:@"SendTo"]) {
        SendToTableViewCell *sendTo = (SendToTableViewCell*)cell;
        sendTo.sendToTextView.delegate = self;
        if (selectedNickname != nil && selectedNickname.length > 0) {
            sendTo.sendToTextView.text = selectedNickname;
        }
        else if (selectedId.length > 0) {
            sendTo.sendToTextView.text = selectedId;
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

    return cell;

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    id<MultiCellItem> item = source.items[indexPath.section];
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
