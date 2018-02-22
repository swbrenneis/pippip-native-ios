//
//  AccountSession.h
//  pippip-native-ios
//
//  Created by Steve Brenneis on 1/25/18.
//  Copyright © 2018 seComm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SessionState.h"
#import "MessageObserver.h"
#import "ContactObserver.h"
#import "ConversationCache.h"
#import "RESTSession.h"
#import "ResponseConsumer.h"
#import "ErrorDelegate.h"

@interface AccountSession : NSObject <ResponseConsumer>

@property (nonatomic) SessionState *sessionState;
@property (weak, nonatomic) RESTSession *restSession;
@property (weak, nonatomic) ConversationCache *conversationCache;

- (void)endSession;

- (void)setContactObserver:(id<ContactObserver>)observer;

- (void)setMessageObserver:(id<MessageObserver>)observer;

- (void)startSession:(SessionState*)state;

- (void)unsetContactObserver:(id<ContactObserver>)observer;

- (void)unsetMessageObserver:(id<MessageObserver>)observer;

@end
