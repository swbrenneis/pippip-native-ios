//
//  MessageManager.m
//  pippip-native-ios
//
//  Created by Steve Brenneis on 1/29/18.
//  Copyright © 2018 seComm. All rights reserved.
//

#import "MessageManager.h"
#import "MessagesDatabase.h"
#import "EnclaveRequest.h"
#import "EnclaveResponse.h"
#import "AlertErrorDelegate.h"
#import "CKIVGenerator.h"
#import "CKGCMCodec.h"

@interface MessageManager ()
{
    MessagesDatabase *messageDatabase;
    NSMutableDictionary *pending;
}

@property (weak, nonatomic) SessionState *sessionState;

@property (weak, nonatomic) id<ResponseConsumer> responseConsumer;
@property (weak, nonatomic) UIViewController *viewController;
@property (weak, nonatomic) RESTSession *session;
@property (weak, nonatomic) ContactManager *contactManager;

@end;

@implementation MessageManager

@synthesize errorDelegate;
@synthesize postPacket;

- (instancetype)initWithRESTSession:(RESTSession *)restSession withContactManager:(ContactManager *)manager {
    self = [super init];
    
    _session = restSession;
    messageDatabase = [[MessagesDatabase alloc] init];
    _contactManager = manager;
    _pendingMessages = [NSMutableArray array];

    return self;
    
}

- (void)addPendingMessage:(NSDictionary*)message {

}

- (void)addReceivedMessages:(NSArray*)messages {

    for (NSDictionary *msg in messages) {
        NSMutableDictionary *message = [NSMutableDictionary dictionary];
        NSString *publicId = msg[@"fromId"];
        message[@"publicId"] = publicId;
        NSDictionary *contact = [_contactManager getContact:publicId];
        message[@"contactId"] = contact[@"contactId"];
        message[@"sent"] = [NSNumber numberWithBool:NO];
        message[@"messageType"] = msg[@"messageType"];
        message[@"keyIndex"] = msg[@"keyIndex"];
        message[@"sequence"] = msg[@"sequence"];
        message[@"timestamp"] = msg[@"timestamp"];
        message[@"acknowledged"] = [NSNumber numberWithBool:NO];
        message[@"body"] = msg[@"body"];
        [messageDatabase addNewMessage:message];
        [self addPendingMessage:message];
    }

}

- (void)endSession {

}

- (NSArray*)getConversation:(NSString *)publicId {

    return messageDatabase.conversations[publicId];

}

- (NSArray*)getMostRecentMessages {

    NSMutableArray *recent = [NSMutableArray array];
    for (NSString *publicId in messageDatabase.conversations) {
        NSArray *conversation = messageDatabase.conversations[publicId];
        [recent addObject:[conversation lastObject]];
    }
    [recent sortUsingComparator:^(id obj1, id obj2) {
        NSDictionary *msg1 = obj1;
        NSNumber *ts1 = msg1[@"timestamp"];
        NSInteger time1 = [ts1 integerValue];
        NSDictionary *msg2 = obj2;
        NSNumber *ts2 = msg2[@"timestamp"];
        NSInteger time2 = [ts2 integerValue];
        if (time1 == time2) {
            NSLog(@"%@", @"Equal message timestamps!");
            return NSOrderedSame;
        }
        else if (time1 > time2) {
            return NSOrderedDescending;
        }
        else {
            return NSOrderedAscending;
        }
    }];

    return recent;

}

- (void)loadMessages {
    
    NSArray *unack = [messageDatabase loadConversations:_contactManager];
    for (NSDictionary *message in unack) {
        [self addPendingMessage:message];
    }

}

- (void)messageAcknowledged:(NSString *)publicId withSequence:(NSInteger)sequence withTimestamp:(NSInteger)timestamp {

    if (pending != nil) {
        pending[@"timestamp"] = [NSNumber numberWithInteger:timestamp];
        pending[@"acknowledged"] = @YES;
        pending[@"publicId"] = pending[@"toId"];
        NSDictionary *contact = [_contactManager getContact:pending[@"toId"]];
        pending[@"contactId"] = contact[@"contactId"];
        NSString *nickname = contact[@"nickname"];
        if (nickname != nil) {
            pending[@"nickname"] = nickname;
        }
        pending[@"sent"] = @YES;
        [messageDatabase addNewMessage:pending];
        pending = nil;
    }

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

- (void)sendMessage:(NSString *)message withPublicId:(NSString *)publicId {

    NSMutableDictionary *contact = [_contactManager getContact:publicId];
    NSNumber *sq = contact[@"currentSequence"];
    NSInteger sequence = [sq integerValue] + 1;
    contact[@"currentSequence"] = [NSNumber numberWithInteger:sequence];
    NSNumber *ky = contact[@"currentIndex"];
    NSInteger keyIndex = [ky integerValue] + 1;
    if (keyIndex > 9) {
        keyIndex = 0;
    }
    contact[@"currentIndex"] = [NSNumber numberWithInteger:keyIndex];
    NSArray *keys = contact[@"messageKeys"];
    NSData *key = keys[keyIndex];
    NSData *authData = contact[@"authData"];
    NSData *nonce = contact[@"nonce"];
    [_contactManager updateContact:contact];

    // Encrypt the message.
    CKIVGenerator *ivGen = [[CKIVGenerator alloc] init];
    NSData *iv = [ivGen generate:sequence withNonce:nonce];
    CKGCMCodec *codec = [[CKGCMCodec alloc] init];
    [codec setIV:iv];
    [codec putString:message];
    NSError *error = nil;
    NSData *encoded = [codec encrypt:key withAuthData:authData withError:&error];
    if (error != nil) {
        NSLog(@"Error while encrypting message: %@", error.localizedDescription);
    }

    // Build the request
    NSMutableDictionary *msg = [NSMutableDictionary dictionary];
    msg[@"method"] = @"SendMessage";
    msg[@"toId"] = publicId;
    msg[@"sequence"] = [NSNumber numberWithInteger:sequence];
    msg[@"keyIndex"] = [NSNumber numberWithInteger:keyIndex];
    msg[@"messageType"] = @"user";
    msg[@"body"] = [encoded base64EncodedStringWithOptions:0];
    pending = msg;
    pending[@"cleartext"] = message;
    [self sendRequest:msg];

}

- (void)sendRequest:(NSDictionary*)request {
    
    EnclaveRequest *enclaveRequest = [[EnclaveRequest alloc] initWithState:_sessionState];
    [enclaveRequest setRequest:request];
    
    postPacket = enclaveRequest;
    [_session queuePost:self];
    
}

- (void)sessionComplete:(NSDictionary*)response {
    // Nothing to do here. Session is already established.
}

- (void)setConfig:(NSDictionary *)config {

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
