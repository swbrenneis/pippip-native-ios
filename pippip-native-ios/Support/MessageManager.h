//
//  MessageManager.h
//  pippip-native-ios
//
//  Created by Steve Brenneis on 1/29/18.
//  Copyright © 2018 seComm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RequestProcess.h"
#import "RESTSession.h"
#import "ResponseConsumer.h"

@class TextMessage;

@interface MessageManager : NSObject <RequestProcess>

- (void)acknowledgePendingMessages;

- (TextMessage*)getMessage:(NSInteger)messageId;

- (NSArray<NSNumber*>*)getMessageIds;

- (NSArray*)getMostRecentMessages;

- (void)getNewMessages;

- (void)messageSent:(NSString*)publicId withSequence:(NSInteger)sequence withTimestamp:(NSInteger)timestamp;

- (void)pendingMessagesAcknowledged;

- (void)sendMessage:(NSString*)message withPublicId:(NSString*)publicId;

- (void)setResponseConsumer:(id<ResponseConsumer>)responseConsumer;

@end
