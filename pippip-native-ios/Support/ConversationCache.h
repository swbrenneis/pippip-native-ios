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

- (void)addNewMessages:(NSArray*)messages;

- (void)deleteAllMessages:(NSString*)publicId;

- (void)deleteMessage:(NSInteger)messageId withPublicId:(NSString*)publicId;

- (Conversation*)getConversation:(NSString*)publicId;

- (NSArray*)getLatestMessageIds:(NSInteger)count withPublicId:(NSString*)publicId;

- (void)markMessageRead:(NSDictionary*)message;

- (NSArray*)mostRecentMessages;

- (NSArray*)unreadMessageIds:(NSString*)publicId;

@end
