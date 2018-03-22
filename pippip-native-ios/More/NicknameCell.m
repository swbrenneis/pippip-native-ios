//
//  NicknameCell.m
//  pippip-native-ios
//
//  Created by Steve Brenneis on 2/23/18.
//  Copyright © 2018 seComm. All rights reserved.
//

#import "NicknameCell.h"
#import "NotificationErrorDelegate.h"
#import "Configurator.h"
#import "ContactManager.h"
#import "ApplicationSingleton.h"

@interface NicknameCell ()
{
    NSString *method;
    NSString *currentNickname;
    NSString *pendingNickname;
    Configurator *config;
    ContactManager *contactManager;
}

@property (weak, nonatomic) IBOutlet UITextField *nicknameTextField;
@property (weak, nonatomic) IBOutlet UIButton *changeNicknameButton;

@end

@implementation NicknameCell

@synthesize errorDelegate;

+ (MoreCellItem*)cellItem {

    MoreCellItem *item = [[MoreCellItem alloc] init];
    item.cellHeight = 65.0;
    item.cellReuseId = @"NicknameCell";
    return item;

}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code

    config = [ApplicationSingleton instance].config;
    contactManager = [[ContactManager alloc] init];
    
    currentNickname = [config getNickname];
    if (currentNickname != nil) {
        _nicknameTextField.text = currentNickname;
    }
    else {
        _nicknameTextField.text = @"";
    }
    [_nicknameTextField setDelegate:self];
    _changeNicknameButton.alpha = 0.0;
    [_changeNicknameButton setEnabled:NO];
    errorDelegate = [[NotificationErrorDelegate alloc] initWithTitle:@"Nickname Error"];

    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(newSession:) name:@"NewSession" object:nil];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)newSession:(NSNotification*)notification {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        currentNickname = [config getNickname];
        if (currentNickname != nil) {
            _nicknameTextField.text = currentNickname;
        }
        else {
            _nicknameTextField.text = @"";
        }
        _changeNicknameButton.alpha = 0.0;
        [_changeNicknameButton setEnabled:NO];
    });
    
}

- (void)response:(NSDictionary *)info {
    
    NSString *result = info[@"result"];
    if ([method isEqualToString:@"MatchNickname"]) {
        if ([result isEqualToString:@"not found"]) {
            method = @"SetNickname";
            [contactManager updateNickname:pendingNickname withOldNickname:currentNickname];
        }
        else if ([result isEqualToString:@"found"]) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Nickname Error"
                                                                            message:@"This nickname is in use, please choose another."
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                               style:UIAlertActionStyleDefault
                                                             handler:nil];
            [alert addAction:okAction];
            NSMutableDictionary *info = [NSMutableDictionary dictionary];
            info[@"alert"] = alert;
            [[NSNotificationCenter defaultCenter] postNotificationName:@"PresentAlert" object:nil userInfo:info];
            dispatch_async(dispatch_get_main_queue(), ^{
                _nicknameTextField.text = currentNickname;
            });
        }
    }
    else {
        NSLog(@"Nickname %@ set", info[@"result"]);
        [config setNickname:pendingNickname];
        currentNickname = pendingNickname;
        pendingNickname = nil;
        dispatch_async(dispatch_get_main_queue(), ^{
            _changeNicknameButton.alpha = 0.0;
            [_changeNicknameButton setEnabled:NO];
        });
    }
    
}
/*
- (void)setViewController:(MoreTableViewController *)view {

    _moreView = view;
    errorDelegate = [[AlertErrorDelegate alloc] initWithViewController:_moreView withTitle:@"Set Nickname Error"];

}
*/
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
            method = @"MatchNickname";
            [contactManager setResponseConsumer:self];
            [contactManager matchNickname:_nicknameTextField.text withPublicId:nil];
        }
        else {
            pendingNickname = nil;
            method = @"SetNickname";
            [contactManager setResponseConsumer:self];
            [contactManager updateNickname:nil withOldNickname:currentNickname];
        }
    }

}

@end
