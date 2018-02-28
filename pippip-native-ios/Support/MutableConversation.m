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

- (instancetype)init {
    self = [super init];

    theDelegate = super.delegate;

    return self;

}

- (instancetype)initWithMessages:(NSArray *)messages {
    self = [super initWithMessages:messages];

    theDelegate = super.delegate;

    return self;

}

- (void)acknowledgeMessage:(NSDictionary *)triplet {
    [theDelegate acknowledgeMessage:triplet];
}

- (void)addMessage:(NSMutableDictionary *)message {
    [theDelegate addMessage:message];
}

- (void)deleteAllMessages {
    [theDelegate deleteAllMessages];
}

- (void)deleteMessage:(NSDictionary *)triplet {
    [theDelegate deleteMessage:triplet];
}

- (NSInteger)markMessageRead:(NSDictionary *)triplet {
    return [theDelegate markMessageRead:triplet];
}

@end
