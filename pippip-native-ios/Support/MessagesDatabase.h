//
//  MessagesDatabase.h
//  pippip-native-ios
//
//  Created by Steve Brenneis on 1/29/18.
//  Copyright © 2018 seComm. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TextMessage;
@class Message;

@interface MessagesDatabase : NSObject

- (void)addTextMessage:(TextMessage*_Nonnull)message;

- (void)addTextMessages:(NSArray<TextMessage*>*_Nonnull)messages;

- (NSArray<NSNumber*>*_Nonnull)allMessageIds;

- (NSArray<TextMessage*>*_Nonnull)allTextMessages;

- (void)deleteAllMessages:(NSInteger)contactId;

- (void)deleteAllMessages;

- (void)deleteMessage:(NSInteger)messageId;

// Returns a raw, encrypted, generic message. Do not downcast.
- (Message*_Nonnull)getMessage:(NSInteger)messageId;

- (NSInteger)getMessageCount:(NSInteger)contactId;

   // Returns a raw, encrypted text message
- (TextMessage*_Nonnull)getTextMessage:(NSInteger)messageId;

// Returns a sorted array of text messages in a subrange. Will not overrun.
- (NSArray<TextMessage*>*_Nonnull)getTextMessages:(NSInteger)contactId
                                     withPosition:(NSInteger)pos
                                        withCount:(NSInteger)count;

- (NSInteger)messageExists:(TextMessage*_Nonnull)message;

- (TextMessage*_Nullable)mostRecentTextMessage:(NSInteger)contactId;

- (void)updateMessage:(Message*_Nonnull)message;

- (void)updateTextMessage:(TextMessage*_Nonnull)message;

@end
