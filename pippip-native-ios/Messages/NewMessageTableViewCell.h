//
//  MessageTableViewCell.h
//  pippip-native-ios
//
//  Created by Steve Brenneis on 2/6/18.
//  Copyright © 2018 seComm. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NewMessageTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UITextField *messageTextField;
@property (weak, nonatomic) IBOutlet UILabel *sendFailedLabel;

@end
