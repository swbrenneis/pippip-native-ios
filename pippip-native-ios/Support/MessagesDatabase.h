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

- (void)deleteAllMessages:(NSString*)publicId;

- (NSArray*)loadConversation:(NSString*)publicId;

- (void)markMessageRead:(NSInteger)messageId;

- (NSDictionary*)mostRecentMessage:(NSInteger)contactId;

- (NSArray*)pendingMessages;

@end
