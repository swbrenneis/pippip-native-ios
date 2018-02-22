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
#import "SessionState.h"
#import "ResponseConsumer.h"

@interface MessageManager : NSObject <RequestProcess>

- (void)acknowledgePendingMessages;

- (void)getNewMessages;

- (void)messageSent:(NSString*)publicId withSequence:(NSInteger)sequence withTimestamp:(NSInteger)timestamp;

- (void)pendingMessagesAcknowledged;

- (void)sendMessage:(NSString*)message withPublicId:(NSString*)publicId;

- (void)setResponseConsumer:(id<ResponseConsumer>)responseConsumer;

//- (void)setViewController:(UIViewController*)controller;

- (void)startNewSession:(SessionState*)state;

@end
