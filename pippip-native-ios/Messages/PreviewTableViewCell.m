//
//  PreviewTableViewCell.m
//  pippip-native-ios
//
//  Created by Steve Brenneis on 2/3/18.
//  Copyright © 2018 seComm. All rights reserved.
//

#import "PreviewTableViewCell.h"

static const NSInteger SEC_PER_HOUR = 3600;
static const NSInteger ONE_DAY = SEC_PER_HOUR * 24;

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
    NSString *contact = message[@"nickname"];
    if (contact == nil) {
        contact = message[@"publicId"];
    }
    if (contact.length > 14) {
        NSString *shortened = [contact substringWithRange:NSMakeRange(0, 14)];
        _senderLabel.text = [shortened stringByAppendingString:@"..."];
    }
    else {
        _senderLabel.text = contact;
    }
    NSNumber *ts = message[@"timestamp"];
    NSString *dt = [self convertTimestamp:[ts integerValue]];
    _dateTimeLabel.text = [dt stringByAppendingString:@" >"];
    NSString *msgText = message[@"cleartext"];
    if (msgText.length > 33) {
        NSString *preview = [msgText substringWithRange:NSMakeRange(0, 33)];
        _previewLabel.text = [preview stringByAppendingString:@"..."];
    }
    else {
        _previewLabel.text = msgText;
    }

}

- (NSString*)convertTimestamp:(NSInteger)timestamp {

    NSInteger ts = timestamp / 1000;
    NSInteger now = [[NSDate date] timeIntervalSince1970];
    NSInteger elapsed = now - ts;
    NSInteger elapsedSinceMidnight = now % ONE_DAY;

    // Yay C!
    struct tm *ts_tm = localtime(&ts);
    char buf[50];
    if (elapsed <= elapsedSinceMidnight) {
        strftime(buf, 50, "%H:%S", ts_tm);
        return [NSString stringWithUTF8String:buf];
    }
    if (elapsed < ONE_DAY) {
        return @"Yesterday";
    }
    else {
        strftime(buf, 50, "%D", ts_tm);   // Localize this for Europe
        return [NSString stringWithUTF8String:buf];
    }

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
