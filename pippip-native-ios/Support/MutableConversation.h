//
//  MutableConversation.h
//  pippip-native-ios
//
//  Created by Steve Brenneis on 2/20/18.
//  Copyright © 2018 seComm. All rights reserved.
//

#import "Conversation.h"

@interface MutableConversation : Conversation

- (instancetype)initWithPublicId:(NSString*)publicId;

- (void)acknowledgeMessage:(NSInteger)messageId;

- (void)addMessage:(NSMutableDictionary*)message;

- (void)deleteAllMessages;

- (void)deleteMessage:(NSInteger)messageId;

- (void)markMessageRead:(NSInteger)messageId;

@end
