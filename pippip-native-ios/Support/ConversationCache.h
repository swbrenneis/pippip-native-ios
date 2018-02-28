//
//  ConversationCache.h
//  pippip-native-ios
//
//  Created by Steve Brenneis on 2/20/18.
//  Copyright © 2018 seComm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SessionState.h"
#import "Conversation.h"

@interface ConversationCache : NSObject

- (void)acknowledgeMessage:(NSDictionary*)message;

- (void)addMessage:(NSMutableDictionary*)message;

- (void)addMessages:(NSArray*)messages;

- (void)deleteAllMessages:(NSString*)publicId;

- (void)deleteMessage:(NSDictionary*)message;

- (Conversation*)getConversation:(NSString*)publicId;

- (void)markMessagesRead:(NSString*)publicId;

- (NSArray*)mostRecentMessages;

@end
