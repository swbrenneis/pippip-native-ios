//
//  AccountSession.h
//  pippip-native-ios
//
//  Created by Steve Brenneis on 1/25/18.
//  Copyright © 2018 seComm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UserNotifications/UserNotifications.h>
#import "ResponseConsumer.h"
#import "ConversationCache.h"
#import "RESTSession.h"

@class SessionState;

@interface AccountSession : NSObject <ResponseConsumer, UNUserNotificationCenterDelegate>

@property (nonatomic) SessionState *sessionState;
@property (weak, nonatomic) RESTSession *restSession;
@property (weak, nonatomic) ConversationCache *conversationCache;
@property (nonatomic) NSData *deviceToken;

//- (void)endSession;

- (void)resume;

- (void)suspend;

//- (void)startSession:(SessionState*)state;

@end
