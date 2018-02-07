//
//  PreviewTableViewCell.m
//  pippip-native-ios
//
//  Created by Steve Brenneis on 2/3/18.
//  Copyright © 2018 seComm. All rights reserved.
//

#import "PreviewTableViewCell.h"

@interface PreviewTableViewCell ()
@property (weak, nonatomic) IBOutlet UIImageView *messageReadImage;
@property (weak, nonatomic) IBOutlet UILabel *senderLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *previewLabel;

@end

@implementation PreviewTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)configure:(NSDictionary*)message {

    NSNumber *read = message[@"read"];
    [_messageReadImage setHidden:[read boolValue]];
    NSString *sender = message[@"sender"];
    if (sender.length > 14) {
        NSString *shortened = [sender substringWithRange:NSMakeRange(0, 14)];
        _senderLabel.text = [shortened stringByAppendingString:@"..."];
    }
    else {
        _senderLabel.text = sender;
    }
    NSString *dt = message[@"dateTime"];
    _dateTimeLabel.text = [dt stringByAppendingString:@" >"];
    NSString *msgText = message[@"message"];
    if (msgText.length > 33) {
        NSString *preview = [msgText substringWithRange:NSMakeRange(0, 33)];
        _previewLabel.text = [preview stringByAppendingString:@"..."];
    }
    else {
        _previewLabel.text = msgText;
    }

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
