//
//  NewMessageDataSource.m
//  pippip-native-ios
//
//  Created by Steve Brenneis on 3/19/18.
//  Copyright © 2018 seComm. All rights reserved.
//

#import "NewMessageDataSource.h"
#import "Conversation.h"
#import "ConversationTableViewCell.h"
#import "ApplicationSingleton.h"
#import "ConversationCache.h"
#import "ContactManager.h"
#import "MBProgressHUD.h"

@interface NewMessageDataSource()
{
    NSDictionary *selectedContact;
    BOOL toConversation;
    BOOL inConversation;
    Conversation *conversation;
    NSMutableArray *messageIds;
    NSMutableArray *contactList;
    ContactManager *contactManager;
    NSInteger lastPartialLength;
}

@property (weak, nonatomic) UITableView *tableView;
@property (weak, nonatomic) ConversationCache *conversationCache;

@end

@implementation NewMessageDataSource

- (instancetype)initWithTableView:(UITableView *)newMessageTableView {
    self = [super init];

    _tableView = newMessageTableView;
    selectedContact = nil;
    toConversation = NO;
    inConversation = NO;
    _conversationCache = [ApplicationSingleton instance].conversationCache;
    contactList = [NSMutableArray array];
    contactManager = [[ContactManager alloc] init];
    lastPartialLength = 0;

    return self;

}

- (void)appSuspended:(NSNotification *)notifictaion {
    [contactList removeAllObjects];
}

- (NSDictionary*)getSelectedContact {
    return selectedContact;
}

- (void)messagesUpdated:(NSNotification*)notification {

    inConversation = YES;
    NSDictionary *messageCount = notification.userInfo;
    NSInteger newMessageCount = [messageCount[@"count"] integerValue];
    NSInteger currentIndex = messageIds.count;
    [messageIds addObjectsFromArray:[_conversationCache getLatestMessageIds:newMessageCount
                                                               withPublicId:selectedContact[@"publicId"]]];
    
    NSMutableArray *paths = [NSMutableArray array];
    for (NSInteger index = currentIndex; index < messageIds.count; index++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0];
        [paths addObject:indexPath];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [_tableView insertRowsAtIndexPaths:paths withRowAnimation:UITableViewRowAnimationBottom];
        [_tableView scrollToRowAtIndexPath:[paths lastObject]
                          atScrollPosition:UITableViewScrollPositionBottom
                                  animated:YES];
    });

}

#pragma - MARK - table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;

}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    if (toConversation) {
        return [self getConversationCell:indexPath];
    }
    else {
        return [self getContactCell:indexPath];
    }

}

- (UITableViewCell*)getConversationCell:(NSIndexPath*)indexPath {

    NSMutableDictionary *message = [conversation getMessage:[messageIds[indexPath.item] integerValue]];
    [_conversationCache markMessageRead:message];
    UITableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:@"MessageCell"
                                                             forIndexPath:indexPath];
    // Configure the cell...
    ConversationTableViewCell *convCell = (ConversationTableViewCell*)cell;
    convCell.contentSize = _tableView.contentSize;
    [convCell configureCell:message];
    
    return convCell;
    
}

- (UITableViewCell*)getContactCell:(NSIndexPath*)indexPath {
    UITableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:@"NewMessageContactCell"];
    
    NSDictionary *contact = contactList[indexPath.item];
    NSString *nickname = contact[@"nickname"];
    NSString *publicId = contact[@"publicId"];
    if (nickname == nil) {
        cell.textLabel.text = publicId;
    }
    else {
        cell.textLabel.text = nickname;
        cell.detailTextLabel.text = publicId;
    }
    [cell setHidden:NO];
    
    return cell;
    
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [messageIds removeObjectAtIndex:indexPath.item];
        [_conversationCache deleteMessage:[messageIds[indexPath.item] integerValue]
                             withPublicId:selectedContact[@"publicId"]];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return inConversation;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    if (toConversation) {
        return [conversation count];
    }
    else {
        return contactList.count;
    }

}


#pragma - MARK - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    if (toConversation) {
        NSMutableDictionary *message = [conversation getMessage:[messageIds[indexPath.item] integerValue]];
        NSNumber *height = message[@"cellHeight"];
        if (height != nil) {
            return [height doubleValue];
        }
    }
    return 44.0;

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    if (![[ApplicationSingleton instance].config getCleartextMessages]) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:tableView animated:YES];
        hud.mode = MBProgressHUDModeIndeterminate;
        hud.label.text = @"Decrypting messages";
    }

    selectedContact = contactList[indexPath.item];
    toConversation = YES;
    conversation = [_conversationCache getConversation:selectedContact[@"publicId"]];
    messageIds = [[conversation allMessageIds] mutableCopy];
    if (messageIds.count > 0 && ![[ApplicationSingleton instance].config getCleartextMessages]) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:tableView animated:YES];
        hud.mode = MBProgressHUDModeIndeterminate;
        hud.label.text = @"Decrypting messages";
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"RecipientSelected" object:nil userInfo:selectedContact];

}

#pragma - MARK - text field delegate

- (void)searchFieldChanged:(NSString*)partial {

    selectedContact = nil;
    toConversation = NO;
    NSInteger newLength = partial.length;
    NSString *fragment = [partial uppercaseString];
    dispatch_async(dispatch_get_main_queue(), ^{
        if (partial == nil || [partial isEqualToString:@""]) {
            [contactList removeAllObjects];
        }
        else if (newLength == 1 || newLength < lastPartialLength) {
            contactList = [[contactManager searchContacts:fragment] mutableCopy];
        }
        else {
            NSMutableArray *newList = [NSMutableArray array];
            for (NSDictionary* contact in contactList) {
                NSString *nickname = [contact[@"nickname"] uppercaseString];
                NSString *publicId = [contact[@"publicId"] uppercaseString];
                if ([publicId containsString:fragment]) {
                    [newList addObject:contact];
                }
                else if (nickname != nil) {
                    if ([nickname containsString:fragment]) {
                        [newList addObject:contact];
                    }
                }
            }
            contactList = newList;
        }
        lastPartialLength = newLength;
        [_tableView reloadData];
    });

}

@end
