//
//  SendToCellItem.m
//  pippip-native-ios
//
//  Created by Steve Brenneis on 2/4/18.
//  Copyright © 2018 seComm. All rights reserved.
//

#import "SendToCellItem.h"

@implementation SendToCellItem

@synthesize type;
@synthesize rowsInItem;
@synthesize cellReuseId;
@synthesize cellHeight;
@synthesize currentCell;

- (instancetype)init {
    self = [super init];

    type = @"SendTo";
    rowsInItem = 1;
    cellReuseId = @"SendToCell";
    cellHeight = 45.0;

    return self;

}

@end
