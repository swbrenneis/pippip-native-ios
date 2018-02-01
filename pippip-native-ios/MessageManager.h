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

- (instancetype)initWithRESTSession:(RESTSession *)restSession;

- (void)loadMessages;

- (NSInteger)senderCount;

- (void)setContactIds:(NSArray*)ids;

- (void)setResponseConsumer:(id<ResponseConsumer>)responseConsumer;

- (void)setSessionState:(SessionState*)state;

- (void)setViewController:(UIViewController*)controller;

@end
