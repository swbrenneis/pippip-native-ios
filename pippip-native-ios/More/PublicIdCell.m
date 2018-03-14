//
//  PublicIdCell.m
//  pippip-native-ios
//
//  Created by Steve Brenneis on 3/1/18.
//  Copyright © 2018 seComm. All rights reserved.
//

#import "PublicIdCell.h"
#import "ApplicationSingleton.h"
#import "CopyableLabel.h"

@interface PublicIdCell ()

@property (weak, nonatomic) IBOutlet UILabel *publicIdLabel;

@end;

@implementation PublicIdCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code

    [self attachTapHandler];
    _publicIdLabel.text = [ApplicationSingleton instance].accountSession.sessionState.publicId;

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)attachTapHandler {
    
    [self setUserInteractionEnabled:YES];
    UIGestureRecognizer *tapped =
        [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    [self addGestureRecognizer:tapped];
    
}

- (void)handleTap:(UIGestureRecognizer*)gesture {
    
    [self becomeFirstResponder];
    UIMenuController *menu = [UIMenuController sharedMenuController];
    [menu setTargetRect:self.frame inView:self.superview];
    [menu setMenuVisible:YES animated:YES];
    
}

- (void)copy:(id)sender {
    
    UIPasteboard *paste = [UIPasteboard generalPasteboard];
    paste.string = _publicIdLabel.text;
    
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    
    return action == @selector(copy:);
    
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

@end
