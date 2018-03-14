//
//  NicknameCell.m
//  pippip-native-ios
//
//  Created by Steve Brenneis on 2/23/18.
//  Copyright © 2018 seComm. All rights reserved.
//

#import "NicknameCell.h"
#import "AlertErrorDelegate.h"
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
@property (weak, nonatomic) IBOutlet UIButton *setNicknameButton;

@property (weak, nonatomic) MoreTableViewController *moreView;

@end

@implementation NicknameCell

@synthesize errorDelegate;

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
    [_setNicknameButton.imageView setTintColor:[UIColor greenColor]];
    [_nicknameTextField setDelegate:self];
    
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
            [_setNicknameButton.imageView setTintColor:[UIColor greenColor]];
        }
        else {
            _nicknameTextField.text = @"";
            [_setNicknameButton.imageView setTintColor:[UIColor redColor]];
        }
    });
    
}

- (void)response:(NSDictionary *)info {
    
    NSString *result = info[@"result"];
    if ([method isEqualToString:@"MatchNickname"]) {
        if ([result isEqualToString:@"not matched"]) {
            method = @"SetNickname";
            [contactManager updateNickname:pendingNickname withOldNickname:currentNickname];
        }
        else if ([result isEqualToString:@"matched"]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [errorDelegate responseError:@"This nickname is in use. Please choose another"];
            });
        }
    }
    else {
        NSLog(@"Nickname %@ set", info[@"result"]);
        [config setNickname:pendingNickname];
        currentNickname = pendingNickname;
        pendingNickname = nil;
        dispatch_async(dispatch_get_main_queue(), ^{
            [_setNicknameButton.imageView setTintColor:[UIColor greenColor]];
        });
    }
    
}

- (void)setViewController:(MoreTableViewController *)view {

    _moreView = view;
    errorDelegate = [[AlertErrorDelegate alloc] initWithViewController:_moreView withTitle:@"Set Nickname Error"];

}
- (IBAction)nicknameDidChange:(UITextField *)sender {

    if (![currentNickname isEqualToString:_nicknameTextField.text]) {
        [_setNicknameButton.imageView setTintColor:[UIColor redColor]];
    }
    else {
        [_setNicknameButton.imageView setTintColor:[UIColor greenColor]];
    }
    
}

- (IBAction)setNickname:(id)sender {

    if (![currentNickname isEqualToString:_nicknameTextField.text]) {
        if (_nicknameTextField.text != nil && _nicknameTextField.text.length > 0) {
            pendingNickname = _nicknameTextField.text;
            method = @"MatchNickname";
            [contactManager setResponseConsumer:self];
            [contactManager matchNickname:_nicknameTextField.text];
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
