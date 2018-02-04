//
//  MessageManager.m
//  pippip-native-ios
//
//  Created by Steve Brenneis on 1/29/18.
//  Copyright © 2018 seComm. All rights reserved.
//

#import "MessageManager.h"
#import "MessagesDatabase.h"
#import "EnclaveResponse.h"
#import "AlertErrorDelegate.h"

@interface MessageManager ()
{
    MessagesDatabase *messages;
}

@property (weak, nonatomic) SessionState *sessionState;

@property (weak, nonatomic) id<ResponseConsumer> responseConsumer;
@property (weak, nonatomic) UIViewController *viewController;
@property (weak, nonatomic) RESTSession *session;

@end;

@implementation MessageManager

@synthesize errorDelegate;
@synthesize postPacket;

- (instancetype)initWithRESTSession:(RESTSession *)restSession {
    self = [super init];
    
    _session = restSession;
    messages = [[MessagesDatabase alloc] init];
    
    return self;
    
}

- (void)endSession {

}

- (NSArray*)getMostRecentMessages {

    return [messages mostRecent];

}

- (void)loadMessages {
    
    [messages loadMessages:_sessionState];
    
}

- (void)postComplete:(NSDictionary*)response {
    
    if (response != nil) {
        EnclaveResponse *enclaveResponse = [[EnclaveResponse alloc] initWithState:_sessionState];
        if ([enclaveResponse processResponse:response errorDelegate:errorDelegate]) {
            NSDictionary *messageResponse = [enclaveResponse getResponse];
            if (messageResponse != nil && _responseConsumer != nil) {
                [_responseConsumer response:messageResponse];
            }
        }
    }
    
}

- (void)sessionComplete:(NSDictionary*)response {
    // Nothing to do here. Session is already established.
}

- (void)setResponseConsumer:(id<ResponseConsumer>)consumer {
    _responseConsumer = consumer;
}

- (void)setSessionState:(SessionState *)state {
    _sessionState = state;
}

- (void)setViewController:(UIViewController *)controller {
    
    _viewController = controller;
    errorDelegate = [[AlertErrorDelegate alloc] initWithViewController:_viewController
                                                             withTitle:@"Contact Error"];
    
}

@end
