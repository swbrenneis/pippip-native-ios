//
//  MessagesDatabase.h
//  pippip-native-ios
//
//  Created by Steve Brenneis on 1/29/18.
//  Copyright © 2018 seComm. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TextMessage;

@interface MessagesDatabase : NSObject

// - (void)acknowledgeMessage:(NSInteger)messageId;

- (NSInteger)addMessage:(TextMessage*_Nonnull)message;

- (void)decryptAll;

//- (NSString*)decryptMessage:(NSDictionary*)message;

//- (void)deleteAllMessages:(NSString*)publicId;

//- (void)deleteMessage:(NSInteger)messageId;

- (TextMessage*_Nonnull)loadTextMessage:(NSInteger)messageId withContactId:(NSInteger)contactId;   // Returns a raw, encrypted message

//- (NSMutableDictionary*)loadMessage:(NSInteger)messageId withPublicId:(NSString*)publicId;

- (NSArray<NSNumber*>*_Nonnull)loadMessageIds:(NSInteger)contactId;

//- (void)markMessageRead:(NSInteger)messageId;

- (TextMessage*)mostRecentMessage:(NSInteger)contactId;

- (NSArray*)pendingMessageInfo;

- (void)scrubCleartext;

//- (NSArray*)unreadMessageIds:(NSString*)publicId;

- (void)updateTimestamp:(NSInteger)messagId withTimestamp:(NSInteger)timestamp;

@end
