//
//  MultiCellItem.h
//  pippip-native-ios
//
//  Created by Steve Brenneis on 2/4/18.
//  Copyright © 2018 seComm. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MultiCellItem <NSObject>

//@property (readonly, nonatomic) NSString *type;
//@property (nonatomic) NSInteger rowsInItem;
@property (nonatomic) NSString *cellReuseId;
@property (nonatomic) CGFloat cellHeight;
@property (weak, nonatomic) UITableViewCell *currentCell;

@end

