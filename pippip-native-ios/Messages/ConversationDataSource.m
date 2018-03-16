//
//  ConversationDataSource.m
//  pippip-native-ios
//
//  Created by Steve Brenneis on 2/11/18.
//  Copyright © 2018 seComm. All rights reserved.
//

#import "ConversationDataSource.h"
#import "ConversationTableViewCell.h"
#import "ConversationCache.h"
#import "Conversation.h"
#import "ApplicationSingleton.h"

@interface ConversationDataSource ()
{
    NSString *publicId;
    Conversation *conversation;
    NSMutableArray *messageIds;
}

@property (weak, nonatomic) ConversationCache *conversationCache;
@property (weak, nonatomic) UITableView *conversationTableView;

@end

@implementation ConversationDataSource
/*
- (instancetype)initWithTableView:(UITableView*)tableView {
    self = [super init];

    _conversationTableView = tableView;
    _conversationCache = [ApplicationSingleton instance].conversationCache;
    conversation = nil;
    messageIds = [NSMutableArray array];
    return self;
    
}
*/
- (instancetype)initWithTableView:(UITableView*)tableView withPublicId:(NSString *)pid {
    self = [super init];

    _conversationTableView = tableView;
    publicId = pid;
    _conversationCache = [ApplicationSingleton instance].conversationCache;
    conversation = [_conversationCache getConversation:publicId];
    messageIds = [[conversation allMessageIds] mutableCopy];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(messagesUpdated:)
                                                 name:@"MessagesUpdated" object:nil];

    return self;

}

- (void)dealloc {

    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"MessagesUpdated" object:nil];

}

- (void)messagesCleared {

    [messageIds removeAllObjects];

}

- (void)messagesUpdated:(NSNotification*)notification {

    NSDictionary *messageCount = notification.userInfo;
    NSInteger newMessageCount = [messageCount[@"count"] integerValue];
    NSInteger currentIndex = messageIds.count;
    [messageIds addObjectsFromArray:[_conversationCache getLatestMessageIds:newMessageCount withPublicId:publicId]];

    NSMutableArray *paths = [NSMutableArray array];
    for (NSInteger index = currentIndex; index < messageIds.count; index++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0];
        [paths addObject:indexPath];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [_conversationTableView insertRowsAtIndexPaths:paths withRowAnimation:UITableViewRowAnimationBottom];
        [_conversationTableView scrollToRowAtIndexPath:[paths lastObject]
                                      atScrollPosition:UITableViewScrollPositionBottom
                                              animated:YES];
    });
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return messageIds.count;

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    NSMutableDictionary *message = [conversation getMessage:[messageIds[indexPath.item] integerValue]];
    [_conversationCache markMessageRead:message];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MessageCell"
                                                            forIndexPath:indexPath];
    // Configure the cell...
    ConversationTableViewCell *convCell = (ConversationTableViewCell*)cell;
    convCell.contentSize = tableView.contentSize;
    [convCell configureCell:message];

    return convCell;

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    NSMutableDictionary *message = [conversation getMessage:[messageIds[indexPath.item] integerValue]];
    NSNumber *height = message[@"cellHeight"];
    if (height != nil) {
        return [height doubleValue];
    }
    else {
        return 44.0;
    }

}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [messageIds removeObjectAtIndex:indexPath.item];
        [_conversationCache deleteMessage:[messageIds[indexPath.item] integerValue] withPublicId:publicId];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
}

@end
