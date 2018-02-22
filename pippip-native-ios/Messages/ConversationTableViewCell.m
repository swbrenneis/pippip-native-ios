//
//  ConversationTableViewCell.m
//  pippip-native-ios
//
//  Created by Steve Brenneis on 2/18/18.
//  Copyright © 2018 seComm. All rights reserved.
//

#import "ConversationTableViewCell.h"
#import "ConversationDataSource.h"

@interface ConversationTableViewCell ()
{
    NSDictionary *message;
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

- (void)configureCell:(NSDictionary *)msg {

    message = msg;
    BOOL sent = [message[@"sent"] boolValue];
    if (sent) {
        [self configureSentMessage];
    }
    else {
        [self configureReceivedMessage];
    }

}

- (void)configureSentMessage {

    CGSize frameSize = self.frame.size;

    // Set fixed constraints
    _messageBubbleTop.constant = 4.0;
    _messageBubbleBottom.constant = 4.0;
    _messageTextTrailing.constant = 10.0;

    NSString *text = message[@"cleartext"];
    _messageText.text = text;
    _messageText.tintColor = [UIColor whiteColor];
    _messageText.numberOfLines = 0;
    _messageText.lineBreakMode = NSLineBreakByWordWrapping;
    _messageTextLeading.constant = (frameSize.width * .333) + 10;
    CGSize maxSize = CGSizeMake((frameSize.width * .667) - 20, CGFLOAT_MAX);
    CGSize labelSize = [_messageText sizeThatFits:maxSize];

    NSString *imageName = @"MessageBubbleRight";
    UIImage *bubble = [[[UIImage imageNamed:imageName]
                        resizableImageWithCapInsets:UIEdgeInsetsMake(17, 21, 17, 21)
                        resizingMode:UIImageResizingModeStretch]
                       imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    _messageBubbleImage.image = bubble;
    _messageBubbleImage.tintColor = [UIColor orangeColor];
    _messageBubbleLeading.constant = frameSize.width - labelSize.width - 20;
    _messageTextLeading.constant = frameSize.width - labelSize.width - 12;

    CGFloat cellHeight = labelSize.height + 28;
    _cellSize = CGSizeMake(frameSize.width, cellHeight);

}

- (void)configureReceivedMessage {

    CGSize frameSize = self.frame.size;

    // Set fixed constraints
    _messageBubbleLeading.constant = 5.0;
    _messageBubbleTop.constant = 4.0;
    _messageBubbleBottom.constant = 4.0;
    _messageTextLeading.constant = 17.0;

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

    CGFloat cellHeight = labelSize.height + 28;
    _cellSize = CGSizeMake(frameSize.width, cellHeight);

}

@end
