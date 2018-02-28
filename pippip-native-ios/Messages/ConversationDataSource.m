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
    NSMutableArray *cells;
}

@property (weak, nonatomic) ConversationCache *conversationCache;

@end

@implementation ConversationDataSource

- (instancetype)init {
    self = [super init];

    _conversationCache = [ApplicationSingleton instance].conversationCache;
    conversation = nil;
    cells = [NSMutableArray array];
    
    return self;
    
}

- (instancetype)initWithPublicId:(NSString *)pid {
    self = [super init];

    publicId = pid;
    _conversationCache = [ApplicationSingleton instance].conversationCache;
    conversation = [_conversationCache getConversation:publicId];
    cells = [NSMutableArray array];

    return self;

}

- (void)messagesUpdated {
    [cells removeAllObjects];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (conversation != nil) {
        return conversation.count;
    }
    else {
        return 0;
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    if (cells.count <= indexPath.item) {
        while (cells.count <= indexPath.item) {
            ConversationTableViewCell *dummy = [[ConversationTableViewCell alloc] init];
            dummy.configured = NO;
            [cells addObject:dummy];
        }
    }
    
    ConversationTableViewCell *convCell = cells[indexPath.item];
    if (!convCell.configured) {
        NSDictionary *message = [conversation getIndexedMessage:indexPath.item];
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MessageCell"
                                                                forIndexPath:indexPath];
        // Configure the cell...
        convCell = (ConversationTableViewCell*)cell;
        [convCell configureCell:message];
        convCell.configured = YES;
        cells[indexPath.item] = cell;

    }
    return convCell;

/*
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MessageCell" forIndexPath:indexPath];
    ConversationTableViewCell *convCell = (ConversationTableViewCell*)cell;
    NSDictionary *message = [conversation getIndexedMessage:indexPath.item];
    [convCell configureCell:message];

    return cell;
*/
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    if (cells.count > indexPath.item) {
        ConversationTableViewCell *cell = cells[indexPath.item];
        return cell.cellSize.height;
    }
    else {
        NSLog(@"Cell size for row %ld not found!", indexPath.item);
        return 20.0;
    }

/*
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    ConversationTableViewCell *convCell = (ConversationTableViewCell*)cell;
    return convCell.cellSize.height;
*/

}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [cells removeAllObjects];
        NSDictionary *message = [conversation getIndexedMessage:indexPath.item];
        [_conversationCache deleteMessage:message];
        [tableView reloadData];
//        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
}

@end
