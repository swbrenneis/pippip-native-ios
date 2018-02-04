//
//  ContactTableViewCell.h
//  pippip-native-ios
//
//  Created by Steve Brenneis on 2/3/18.
//  Copyright © 2018 seComm. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ContactTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *statusImageView;
@property (weak, nonatomic) IBOutlet UILabel *publicIdLabel;
@property (weak, nonatomic) IBOutlet UILabel *nicknameLabel;

@end
