//
//  ConversationRightTableViewCell.m
//  pippip-native-ios
//
//  Created by Steve Brenneis on 2/10/18.
//  Copyright © 2018 seComm. All rights reserved.
//

#import "ConversationRightTableViewCell.h"

@interface ConversationRightTableViewCell ()

@property (weak, nonatomic) IBOutlet UIImageView *messageBubbleImage;
@property (weak, nonatomic) IBOutlet UILabel *messageText;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageTextLeading;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageBubbleLeading;

@end

@implementation ConversationRightTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (CGSize)configureCell:(NSDictionary*)message {

    CGSize cellSize = self.frame.size;
    
    NSString *text = message[@"cleartext"];
    _messageText.text = text;
    _messageText.tintColor = [UIColor whiteColor];
    _messageText.numberOfLines = 0;
    _messageText.lineBreakMode = NSLineBreakByWordWrapping;
    _messageTextLeading.constant = (cellSize.width * .333) + 10;
    CGSize maxSize = CGSizeMake((cellSize.width * .667) - 20, CGFLOAT_MAX);
    CGSize labelSize = [_messageText sizeThatFits:maxSize];
    
    NSString *imageName = @"MessageBubbleRight";
    UIImage *bubble = [[[UIImage imageNamed:imageName]
                        resizableImageWithCapInsets:UIEdgeInsetsMake(17, 21, 17, 21)
                        resizingMode:UIImageResizingModeStretch]
                       imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    _messageBubbleImage.image = bubble;
    _messageBubbleImage.tintColor = [UIColor orangeColor];
    _messageBubbleLeading.constant = cellSize.width - labelSize.width - 20;
    _messageTextLeading.constant = cellSize.width - labelSize.width - 12;

    CGFloat cellHeight = labelSize.height + 24;
    return CGSizeMake(cellSize.width, cellHeight);
    
}

@end
