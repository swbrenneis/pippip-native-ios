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
#import "ContactManager.h"

@interface MessageManager : NSObject <RequestProcess>

@property (nonatomic) NSMutableArray *pendingMessages;

- (instancetype)initWithRESTSession:(RESTSession *)restSession withContactManager:(ContactManager*)manager;

- (void)addReceivedMessages:(NSArray*)messages;

- (void)endSession;

- (NSArray*)getConversation:(NSString*)publicId;

- (NSArray*)getMostRecentMessages;

- (void)loadMessages;

- (void)messageAcknowledged:(NSString*)publicId withSequence:(NSInteger)sequence withTimestamp:(NSInteger)timestamp;

- (void)sendMessage:(NSString*)message withPublicId:(NSString*)publicId;

- (void)setConfig:(NSDictionary*)config;

- (void)setResponseConsumer:(id<ResponseConsumer>)responseConsumer;

- (void)setSessionState:(SessionState*)state;

- (void)setViewController:(UIViewController*)controller;

@end
