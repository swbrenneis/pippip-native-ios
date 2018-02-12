//
//  ConversationDataSource.m
//  pippip-native-ios
//
//  Created by Steve Brenneis on 2/11/18.
//  Copyright © 2018 seComm. All rights reserved.
//

#import "ConversationDataSource.h"
#import "ConversationLeftTableViewCell.h"
#import "ConversationRightTableViewCell.h"

@interface ConversationDataSource ()
{
    NSArray *conversation;
    NSMutableArray *cellSizes;
}

@end

@implementation ConversationDataSource

- (instancetype)init {
    self = [super init];

    cellSizes = [NSMutableArray array];

    return self;

}

- (void)setConversation:(NSArray *)conv {

    conversation = conv;
    [cellSizes removeAllObjects];
    while (cellSizes.count < conversation.count) {
        [cellSizes addObject:[NSValue valueWithCGSize:CGSizeMake(0, 0)]];
    }

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
    
    NSDictionary *message = conversation[indexPath.item];
    NSNumber *s = message[@"sent"];
    BOOL sent = [s boolValue];
    
    // Configure the cell...
    if (sent) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ConversationCellRight"
                                                                forIndexPath:indexPath];
        ConversationRightTableViewCell *conversationCell = (ConversationRightTableViewCell*)cell;
        CGSize cellSize = [conversationCell configureCell:message];
        cellSizes[indexPath.item] = [NSValue valueWithCGSize:cellSize];
        return cell;
    }
    else {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ConversationCellLeft"
                                                                forIndexPath:indexPath];
        ConversationLeftTableViewCell *conversationCell = (ConversationLeftTableViewCell*)cell;
        CGSize cellSize = [conversationCell configureCell:message];
        cellSizes[indexPath.item] = [NSValue valueWithCGSize:cellSize];
        return cell;
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSValue *cellSize  = cellSizes[indexPath.item];
    return cellSize.CGSizeValue.height;
    
}

@end
