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

    ApplicationSingleton *app = [ApplicationSingleton instance];
    _conversationCache = app.conversationCache;
    conversation = nil;
    cells = [NSMutableArray array];
    
    return self;
    
}

- (instancetype)initWithPublicId:(NSString *)pid {
    self = [super init];

    publicId = pid;
    ApplicationSingleton *app = [ApplicationSingleton instance];
    _conversationCache = app.conversationCache;
    conversation = [_conversationCache getConversation:publicId];
    cells = [NSMutableArray array];

    return self;

}

- (void)newMessageAdded {
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

@end
