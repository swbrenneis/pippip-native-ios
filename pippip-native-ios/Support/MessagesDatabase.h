//
//  MessagesDatabase.h
//  pippip-native-ios
//
//  Created by Steve Brenneis on 1/29/18.
//  Copyright © 2018 seComm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SessionState.h"

@interface MessagesDatabase : NSObject

- (void)acknowledgeMessage:(NSInteger)messageId;

- (NSInteger)addMessage:(NSDictionary*)message;

- (void)decryptAll;

- (NSString*)decryptMessage:(NSDictionary*)message;

- (void)deleteAllMessages:(NSString*)publicId;

- (void)deleteMessage:(NSInteger)messageId;

- (NSMutableDictionary*)loadMessage:(NSInteger)messageId withPublicId:(NSString*)publicId;

- (NSArray*)loadMessageIds:(NSString*)publicId;

- (void)markMessageRead:(NSInteger)messageId;

- (NSDictionary*)mostRecentMessage:(NSInteger)contactId;

- (NSArray*)pendingMessages;

- (void)scrubCleartext;

- (NSArray*)unreadMessageIds:(NSString*)publicId;

@end
