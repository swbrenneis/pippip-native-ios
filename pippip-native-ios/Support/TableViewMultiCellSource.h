//
//  TableViewMultiCellSource.h
//  pippip-native-ios
//
//  Created by Steve Brenneis on 2/4/18.
//  Copyright © 2018 seComm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MultiCellItem.h"

@protocol TableViewMultiCellSource <NSObject>

@property (nonatomic) NSArray< id<MultiCellItem> > *items;

@end

