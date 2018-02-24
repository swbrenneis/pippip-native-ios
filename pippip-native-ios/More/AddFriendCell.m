//
//  AddFriendCell.m
//  pippip-native-ios
//
//  Created by Steve Brenneis on 2/23/18.
//  Copyright © 2018 seComm. All rights reserved.
//

#import "AddFriendCell.h"

@interface AddFriendCell ()
{
    
}

@property (weak, nonatomic) IBOutlet UITextField *nicknameTextField;
@property (weak, nonatomic) IBOutlet UITextField *publicIdTextField;
@property (weak, nonatomic) WhitelistViewController *whitelistView;

@end

@implementation AddFriendCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setViewController:(WhitelistViewController *)view {
    _whitelistView = view;
}

- (IBAction)addFriend:(UIButton *)sender {

    [_whitelistView addFriend:_nicknameTextField.text withPublicId:_publicIdTextField.text];
    _nicknameTextField.text = @"";
    _publicIdTextField.text = @"";

}

- (IBAction)cancelAdd:(UIButton *)sender {

    _nicknameTextField.text = @"";
    _publicIdTextField.text = @"";
    [_whitelistView cancelAddFriend];

}

@end
