//
//  CopyableLabel.m
//  pippip-native-ios
//
//  Created by Steve Brenneis on 3/1/18.
//  Copyright © 2018 seComm. All rights reserved.
//

#import "CopyableLabel.h"

@implementation CopyableLabel

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];

    [self attachTapHandler];

    return self;

}

- (void)awakeFromNib {

    [super awakeFromNib];
    [self attachTapHandler];

}

- (void)attachTapHandler {

    [self setUserInteractionEnabled:YES];
    UIGestureRecognizer *tapped = [[UIGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
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
    paste.string = self.text;

}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {

    return action == @selector(copy:);

}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

@end
