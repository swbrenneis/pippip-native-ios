//
//  ContactSearchCellItem.m
//  pippip-native-ios
//
//  Created by Steve Brenneis on 2/4/18.
//  Copyright © 2018 seComm. All rights reserved.
//

#import "ContactSearchCellItem.h"

@implementation ContactSearchCellItem

@synthesize type;
@synthesize rowsInItem;
@synthesize cellReuseId;
@synthesize cellHeight;

- (instancetype)init {
    self = [super init];

    type = @"ContactSearch";
    rowsInItem = 1;
    cellReuseId = @"ContactSearchCell";
    cellHeight = 250.0;

    return self;

}

@end
