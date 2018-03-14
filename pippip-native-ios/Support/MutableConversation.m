//
//  MutableConversation.m
//  pippip-native-ios
//
//  Created by Steve Brenneis on 2/20/18.
//  Copyright © 2018 seComm. All rights reserved.
//

#import "MutableConversation.h"
#import "ConversationDelegate.h"

@interface MutableConversation ()
{
    ConversationDelegate *theDelegate;
}

@end

@implementation MutableConversation

- (instancetype)initWithPublicId:(NSString *)publicId {
    self = [super initWithPublicId:publicId];

    theDelegate = super.delegate;

    return self;

}
/*
- (instancetype)initWithMessageIds:(NSArray *)messages {
    self = [super initWithMessageIds:messages];

    theDelegate = super.delegate;

    return self;

}
*/
- (void)acknowledgeMessage:(NSInteger)messageId {
    [theDelegate acknowledgeMessage:messageId];
}

- (void)addMessage:(NSMutableDictionary *)message {
    [theDelegate addMessage:message];
}

- (void)deleteAllMessages {
    [theDelegate deleteAllMessages];
}

- (void)deleteMessage:(NSInteger)messageId {
    [theDelegate deleteMessage:messageId];
}

- (void)markMessageRead:(NSInteger)messageId {
    [theDelegate markMessageRead:messageId];
}

@end
