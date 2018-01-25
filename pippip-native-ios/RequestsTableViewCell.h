//
//  RequestsTableViewCell.h
//  pippip-native-ios
//
//  Created by Steve Brenneis on 1/15/18.
//  Copyright © 2018 seComm. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RequestsTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *nicknameLabel;
@property (weak, nonatomic) IBOutlet UILabel *publicIdLabel;

@end
