//
//  NewMessageCellSource.m
//  pippip-native-ios
//
//  Created by Steve Brenneis on 2/4/18.
//  Copyright © 2018 seComm. All rights reserved.
//

#import "NewMessageCellSource.h"
#import "SendToCellItem.h"
#import "ContactSearchCellItem.h"
#import "NewMessageCellItem.h"

@implementation NewMessageCellSource

@synthesize items;

- (instancetype)init {
    self = [super init];

    NSMutableArray *nmItems = [NSMutableArray array];
    SendToCellItem *sendTo = [[SendToCellItem alloc] init];
    [nmItems addObject:sendTo];
    ContactSearchCellItem *search = [[ContactSearchCellItem alloc] init];
    [nmItems addObject:search];
    NewMessageCellItem *newMessage = [[NewMessageCellItem alloc] init];
    [nmItems addObject:newMessage];
    items = nmItems;

    return self;

}

- (NSInteger)numberOfCellsInSource {
    return 1;
}

@end
