//
//  AccountSession.h
//  pippip-native-ios
//
//  Created by Steve Brenneis on 1/25/18.
//  Copyright © 2018 seComm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SessionState.h"
#import "ConversationCache.h"
#import "RESTSession.h"
#import "ResponseConsumer.h"
#import "ErrorDelegate.h"

@interface AccountSession : NSObject <ResponseConsumer>

@property (nonatomic) SessionState *sessionState;
@property (weak, nonatomic) RESTSession *restSession;
@property (weak, nonatomic) ConversationCache *conversationCache;

- (void)endSession;

- (void)resume;

- (void)suspend;

- (void)startSession:(SessionState*)state;

@end
