//
//  NicknameCell.h
//  pippip-native-ios
//
//  Created by Steve Brenneis on 2/23/18.
//  Copyright © 2018 seComm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MoreTableViewController.h"
#import "ResponseConsumer.h"

@interface NicknameCell : UITableViewCell <ResponseConsumer, UITextFieldDelegate>

- (void)setViewController:(MoreTableViewController*)view;

@end
