//
//  NicknameCell.h
//  pippip-native-ios
//
//  Created by Steve Brenneis on 2/23/18.
//  Copyright © 2018 seComm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MoreCellItem.h"

@interface NicknameCell : UITableViewCell <UITextFieldDelegate>

+ (MoreCellItem*)cellItem;

- (void)nicknameMatched:(NSNotification*)notification;

- (void)nicknameUpdated:(NSNotification*)notification;

@end
