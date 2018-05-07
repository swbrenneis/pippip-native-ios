//
//  NicknameCell.m
//  pippip-native-ios
//
//  Created by Steve Brenneis on 2/23/18.
//  Copyright © 2018 seComm. All rights reserved.
//

#import "NicknameCell.h"
#import "pippip_native_ios-Swift.h"
#import "ApplicationSingleton.h"
#import "Notifications.h"

@interface NicknameCell ()
{
    NSString *currentNickname;
    NSString *pendingNickname;
    Configurator *config;
    ContactManager *contactManager;
    id<ErrorDelegate> errorDelegate;
}

@property (weak, nonatomic) IBOutlet UITextField *nicknameTextField;
@property (weak, nonatomic) IBOutlet UIButton *changeNicknameButton;

@end

@implementation NicknameCell

+ (MoreCellItem*)cellItem {

    MoreCellItem *item = [[MoreCellItem alloc] init];
    item.cellHeight = 65.0;
    item.cellReuseId = @"NicknameCell";
    return item;

}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code

    config = [[Configurator alloc] init];
    contactManager = [[ContactManager alloc] init];
    
    currentNickname = config.nickname;
    if (currentNickname != nil) {
        _nicknameTextField.text = currentNickname;
    }
    else {
        _nicknameTextField.text = @"";
    }
    [_nicknameTextField setDelegate:self];
    _changeNicknameButton.alpha = 0.0;
    [_changeNicknameButton setEnabled:NO];

    errorDelegate = [[NotificationErrorDelegate alloc] init:@"Nickname Error"];

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
    if (selected) {
        [_nicknameTextField becomeFirstResponder];
    }

}

- (void)newSession:(NSNotification*)notification {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self->currentNickname = self->config.nickname;
        if (self->currentNickname != nil) {
            self->_nicknameTextField.text = self->currentNickname;
        }
        else {
            self->_nicknameTextField.text = @"";
        }
        self->_changeNicknameButton.alpha = 0.0;
        [self->_changeNicknameButton setEnabled:NO];
    });
    
}

- (void)nicknameMatched:(NSNotification*)notification {

    NSDictionary *info = notification.userInfo;
    NSString *result = info[@"result"];
    if ([result isEqualToString:@"not found"]) {
        [contactManager updateNicknameWithNewNickname:pendingNickname oldNickname:currentNickname];
    }
    else if ([result isEqualToString:@"found"]) {
        [errorDelegate responseError:@"This nickname is in use, please choose another."];
        dispatch_async(dispatch_get_main_queue(), ^{
            self->_nicknameTextField.text = self->currentNickname;
        });
    }

}

- (void)nicknameUpdated:(NSNotification*)notification {

    NSDictionary *info = notification.userInfo;
    NSLog(@"Nickname %@ set", info[@"result"]);
    config.nickname = pendingNickname;
    currentNickname = pendingNickname;
    pendingNickname = nil;
    dispatch_async(dispatch_get_main_queue(), ^{
        self->_changeNicknameButton.alpha = 0.0;
        [self->_changeNicknameButton setEnabled:NO];
    });

}

- (void)response:(NSDictionary *)info {
    
}

- (IBAction)nicknameDidChange:(UITextField *)sender {

    if (![currentNickname isEqualToString:_nicknameTextField.text]) {
        _changeNicknameButton.alpha = 1.0;
        [_changeNicknameButton setEnabled:YES];
    }
    else {
        _changeNicknameButton.alpha = 0.0;
        [_changeNicknameButton setEnabled:NO];
    }
    
}

- (IBAction)changeNickname:(UIButton *)sender {

    if (![currentNickname isEqualToString:_nicknameTextField.text]) {
        if (_nicknameTextField.text != nil && _nicknameTextField.text.length > 0) {
            pendingNickname = _nicknameTextField.text;
            [contactManager matchNicknameWithNickname:_nicknameTextField.text publicId:nil];
        }
        else {
            pendingNickname = nil;
            [contactManager updateNicknameWithNewNickname:nil oldNickname:currentNickname];
        }
    }

}

@end
