//
//  PreviewCell.m
//  pippip-native-ios
//
//  Created by Steve Brenneis on 2/3/18.
//  Copyright © 2018 seComm. All rights reserved.
//

#import "pippip_native_ios-Swift.h"
#import "PreviewCell.h"
#import "Notifications.h"

static const NSInteger SEC_PER_HOUR = 3600;
static const NSInteger ONE_DAY = SEC_PER_HOUR * 24;

@interface PreviewCell ()
{
    TextMessage *textMessage;
    ContactManager *contactManager;
    BOOL configured;
}

@property (weak, nonatomic) IBOutlet UIImageView *messageReadImage;
@property (weak, nonatomic) IBOutlet UILabel *senderLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *previewLabel;

@end

@implementation PreviewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    contactManager = [[ContactManager alloc] init];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(cleartextAvailable:)
                                                 name:CLEARTEXT_AVAILABLE
                                               object:nil];

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
    configured = NO;

}

- (void)dealloc {

    [[NSNotificationCenter defaultCenter] removeObserver:self name:CLEARTEXT_AVAILABLE object:nil];

}

- (void)configure:(TextMessage*)message {

    [_messageReadImage setHidden:message.read];
    if (!configured) {
        configured = YES;
        textMessage = message;
        Contact *contact = [contactManager getContactById:message.contactId];
        _senderLabel.text = contact.displayName;
        NSString *dt = [self convertTimestamp:message.timestamp];
        _dateTimeLabel.text = [dt stringByAppendingString:@" >"];
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0), ^{
            [message decrypt:false];    // noNotify = false
        });
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

- (TextMessage*)getTextMessage {
    return textMessage;
}

- (void)setMessageText:(NSString*)msgText {

    if (msgText.length > 33) {
        NSString *preview = [msgText substringWithRange:NSMakeRange(0, 33)];
        _previewLabel.text = [preview stringByAppendingString:@"..."];
    }
    else {
        _previewLabel.text = msgText;
    }

}

- (void)cleartextAvailable:(NSNotification*)notification {

    TextMessage *message = (TextMessage*)notification.object;
    if (message.messageId == textMessage.messageId) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self setMessageText:self->textMessage.cleartext];
        });
    }

}
     
@end
