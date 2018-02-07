//
//  NewMessageCellItem.m
//  pippip-native-ios
//
//  Created by Steve Brenneis on 2/4/18.
//  Copyright © 2018 seComm. All rights reserved.
//

#import "NewMessageCellItem.h"

@implementation NewMessageCellItem

@synthesize type;
@synthesize rowsInItem;
@synthesize cellReuseId;
@synthesize cellHeight;
@synthesize currentCell;

- (instancetype)init {
    self = [super init];

    type = @"NewMessage";
    rowsInItem = 1;
    cellReuseId = @"NewMessageCell";
    cellHeight = 60.0;

    return self;

}

@end
