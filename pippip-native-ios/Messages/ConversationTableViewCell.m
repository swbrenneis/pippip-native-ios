//
//  ConversationTableViewCell.m
//  pippip-native-ios
//
//  Created by Steve Brenneis on 2/18/18.
//  Copyright © 2018 seComm. All rights reserved.
//

#import "ConversationTableViewCell.h"

@interface ConversationTableViewCell ()
{
    UIColor *sentColor;
    UIColor *receivedColor;
}
@property (weak, nonatomic) IBOutlet UIImageView *messageBubbleImage;
@property (weak, nonatomic) IBOutlet UILabel *messageText;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageBubbleLeading;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageBubbleBottom;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageBubbleTrailing;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageBubbleTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageTextBottom;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageTextLeading;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageTextTrailing;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageTextTop;

@end

@implementation ConversationTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)configureCell:(NSMutableDictionary *)msg {

    BOOL sent = [msg[@"sent"] boolValue];
    NSValue *value = msg[@"bubbleSize"];
    CGSize bubbleSize = CGSizeMake(44.0, 44.0);;
    if (value != nil) {
        bubbleSize = value.CGSizeValue;
    }
    else {
        bubbleSize = [self calculatebubbleSize:msg];
        msg[@"bubbleSize"] = [NSValue valueWithCGSize:bubbleSize];
        msg[@"cellHeight"] = [NSNumber numberWithDouble:bubbleSize.height + 8];
    }
    if (sent) {
        sentColor = [[UIColor alloc] initWithRed:240.0 / 255.0
                                           green:130.0 / 255.0
                                            blue:39.0 / 255.0
                                           alpha:1.0];
        [self setSentConstraints:bubbleSize];
        [self configureSentMessage:msg];
    }
    else {
        receivedColor = [[UIColor alloc] initWithRed:219.0 / 255.0
                                               green:219.0 / 255.0
                                                blue:219.0 / 255.0
                                               alpha:1.0];
        [self setReceivedConstraints:bubbleSize];
        [self configureReceivedMessage:msg];
    }

}

- (CGSize)calculatebubbleSize:(NSDictionary*)message {

    _messageTextTrailing.constant = 16.0;
    _messageTextLeading.constant = (_contentSize.width * .333) + 16;
    NSString *text = message[@"cleartext"];
    _messageText.text = text;
    _messageText.numberOfLines = 0;
    _messageText.lineBreakMode = NSLineBreakByWordWrapping;
    CGSize maxSize = CGSizeMake((_contentSize.width * .667) - 28, CGFLOAT_MAX);
    CGSize labelSize = [_messageText sizeThatFits:maxSize];
    return CGSizeMake(labelSize.width + 28.0, labelSize.height + 22.0);

}

- (void)configureSentMessage:(NSDictionary*)message {

    NSString *text = message[@"cleartext"];
    _messageText.text = text;
    _messageText.textColor = [UIColor whiteColor];
    _messageText.numberOfLines = 0;
    _messageText.lineBreakMode = NSLineBreakByWordWrapping;

    NSString *imageName = @"MessageBubbleRight";
    UIImage *bubble = [[[UIImage imageNamed:imageName]
                        resizableImageWithCapInsets:UIEdgeInsetsMake(21, 21, 21, 21)
                        resizingMode:UIImageResizingModeStretch]
                       imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    _messageBubbleImage.image = bubble;
    _messageBubbleImage.tintColor = sentColor;

}

- (void)configureReceivedMessage:(NSDictionary*)message {

    NSString *text = message[@"cleartext"];
    _messageText.text = text;
    _messageText.textColor = [UIColor blackColor];
    _messageText.numberOfLines = 0;
    _messageText.lineBreakMode = NSLineBreakByWordWrapping;

    NSString *imageName = @"MessageBubbleLeft";
    UIImage *bubble = [[[UIImage imageNamed:imageName]
                        resizableImageWithCapInsets:UIEdgeInsetsMake(17, 21, 17, 21)
                        resizingMode:UIImageResizingModeStretch]
                       imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    _messageBubbleImage.image = bubble;
    _messageBubbleImage.tintColor = receivedColor;

}

- (void)setReceivedConstraints:(CGSize)bubbleSize {

    _messageBubbleTop.constant = 4.0;
    _messageBubbleBottom.constant = 4.0;
    _messageBubbleLeading.constant = 0.0;
    _messageBubbleTrailing.constant = _contentSize.width - bubbleSize.width;
    _messageTextTop.constant = 0.0;
    _messageTextBottom.constant = 0.0;
    _messageTextLeading.constant = 16.0;
    _messageTextTrailing.constant = _messageBubbleTrailing.constant + 12.0;

}

- (void)setSentConstraints:(CGSize)bubbleSize {

    _messageBubbleTop.constant = 4.0;
    _messageBubbleBottom.constant = 4.0;
    _messageBubbleTrailing.constant = 0.0;
    _messageBubbleLeading.constant = _contentSize.width - bubbleSize.width;
    _messageTextTop.constant = 0.0;
    _messageTextBottom.constant = 0.0;
    _messageTextTrailing.constant = 16.0;
    _messageTextLeading.constant = _messageBubbleLeading.constant + 12.0;
    
}

@end
