//
//  ConversationLeftTableViewCell.m
//  pippip-native-ios
//
//  Created by Steve Brenneis on 2/9/18.
//  Copyright © 2018 seComm. All rights reserved.
//

#import "ConversationLeftTableViewCell.h"

@interface ConversationLeftTableViewCell ()

@property (weak, nonatomic) IBOutlet UIImageView *messageBubbleImage;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageTextTrailing;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageBubbleTrailing;
@property (weak, nonatomic) IBOutlet UILabel *messageText;

@end

@implementation ConversationLeftTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)configureCell:(NSDictionary*)message {

    CGSize frameSize = self.frame.size;
    
    NSString *text = message[@"cleartext"];
    _messageText.text = text;
    _messageText.tintColor = [UIColor whiteColor];
    _messageText.numberOfLines = 0;
    _messageText.lineBreakMode = NSLineBreakByWordWrapping;
    _messageTextTrailing.constant = (frameSize.width * .333) + 10;
    CGSize maxSize = CGSizeMake((frameSize.width * .667) - 20, CGFLOAT_MAX);
    CGSize labelSize = [_messageText sizeThatFits:maxSize];
    
    NSString *imageName = @"MessageBubbleLeft";
    UIImage *bubble = [[[UIImage imageNamed:imageName]
                        resizableImageWithCapInsets:UIEdgeInsetsMake(17, 21, 17, 21)
                        resizingMode:UIImageResizingModeStretch]
                       imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    _messageBubbleImage.image = bubble;
    _messageBubbleImage.tintColor = [UIColor lightGrayColor];
    _messageBubbleTrailing.constant = frameSize.width - labelSize.width - 22;
    
    CGFloat cellHeight = labelSize.height + 24;
    _cellSize = CGSizeMake(frameSize.width, cellHeight);
    
}

@end
