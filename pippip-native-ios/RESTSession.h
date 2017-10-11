//
//  RESTSession.h
//  pippip-native-ios
//
//  Created by Steve Brenneis on 10/10/17.
//  Copyright © 2017 seComm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SessionState.h"
#import "RESTRequestDelegate.h"
#import "SessionDelegate.h"
#import "PostPacket.h"

@interface RESTSession : NSObject <NSURLConnectionDelegate>

@property (nonatomic, readonly) SessionState *sessionState;

- (instancetype)initWithState:(SessionState*)state;

- (void)doPost:(id<PostPacket>)packet withDelegate:(id<RESTRequestDelegate>)delegate;

- (void)startSession:(id<SessionDelegate>)delegate;

@end
