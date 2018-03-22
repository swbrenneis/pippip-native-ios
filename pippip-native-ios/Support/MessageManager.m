//
//  MessageManager.m
//  pippip-native-ios
//
//  Created by Steve Brenneis on 1/29/18.
//  Copyright © 2018 seComm. All rights reserved.
//

#import "MessageManager.h"
#import "ApplicationSingleton.h"
#import "ConversationCache.h"
#import "ContactDatabase.h"
#import "EnclaveRequest.h"
#import "EnclaveResponse.h"
#import "MessagesDatabase.h"
#import "CKIVGenerator.h"
#import "CKGCMCodec.h"

@interface MessageManager ()
{
    ContactDatabase *contactDatabase;
    MessagesDatabase *messageDatabase;
    NSMutableDictionary *sentMessage;
    NSArray *pendingMessages;
}

//@property (weak, nonatomic) SessionState *sessionState;
@property (weak, nonatomic) id<ResponseConsumer> responseConsumer;
@property (weak, nonatomic) RESTSession *session;
//@property (weak, nonatomic) ConversationCache *conversationCache;

@end;

@implementation MessageManager

@synthesize errorDelegate;
@synthesize postPacket;

- (instancetype)init {
    self = [super init];

    _session = nil;
    contactDatabase = [[ContactDatabase alloc] init];
    messageDatabase = [[MessagesDatabase alloc] init];
//    _conversationCache = nil;

//    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(newSession:) name:@"NewSession" object:nil];

    return self;
    
}

- (void)acknowledgePendingMessages {

    pendingMessages = [messageDatabase pendingMessages];
    NSMutableDictionary *request = [NSMutableDictionary dictionary];
    request[@"method"] = @"AcknowledgeMessages";
    NSMutableArray *triplets = [NSMutableArray array];
    for (NSDictionary *message in pendingMessages) {
        NSMutableDictionary *triplet = [NSMutableDictionary dictionary];
        triplet[@"publicId"] = message[@"publicId"];
        triplet[@"sequence"] = message[@"sequence"];
        triplet[@"timestamp"] = message[@"timestamp"];
        [triplets addObject:triplet];
    }
    request[@"messages"] = triplets;
    [self sendRequest:request];

}

/*
- (void)addReceivedMessages:(NSArray*)messages {

    for (NSDictionary *msg in messages) {
        NSMutableDictionary *message = [NSMutableDictionary dictionary];
        NSString *publicId = msg[@"fromId"];
        message[@"publicId"] = publicId;
        NSDictionary *contact = [contactDatabase getContact:publicId];
        message[@"contactId"] = contact[@"contactId"];
        message[@"sent"] = [NSNumber numberWithBool:NO];
        message[@"messageType"] = msg[@"messageType"];
        message[@"keyIndex"] = msg[@"keyIndex"];
        message[@"sequence"] = msg[@"sequence"];
        message[@"timestamp"] = msg[@"timestamp"];
        message[@"acknowledged"] = [NSNumber numberWithBool:NO];
        message[@"body"] = msg[@"body"];
        [messageDatabase addNewMessage:message];
    }

}
*/

- (void)getNewMessages {

    NSMutableDictionary *request = [NSMutableDictionary dictionary];
    request[@"method"] = @"GetMessages";
    [self sendRequest:request];

}

- (void)messageSent:(NSString *)publicId withSequence:(NSInteger)sequence withTimestamp:(NSInteger)timestamp {

    if (sentMessage != nil) {
        sentMessage[@"timestamp"] = [NSNumber numberWithInteger:timestamp];
        sentMessage[@"acknowledged"] = @YES;
        sentMessage[@"read"] = @NO;
        sentMessage[@"publicId"] = sentMessage[@"toId"];
        NSDictionary *contact = [contactDatabase getContact:sentMessage[@"toId"]];
        sentMessage[@"contactId"] = contact[@"contactId"];
        NSString *nickname = contact[@"nickname"];
        if (nickname != nil) {
            sentMessage[@"nickname"] = nickname;
        }
        sentMessage[@"sent"] = @YES;
        [[ApplicationSingleton instance].conversationCache addMessage:sentMessage];
        sentMessage = nil;
    }

}
/*
- (void)newSession:(NSNotification*)notification {
    
    _sessionState = (SessionState*)notification.object;
    _conversationCache = [ApplicationSingleton instance].conversationCache;

}
*/
- (void)pendingMessagesAcknowledged {
    
    for (NSDictionary *message in pendingMessages) {
        [[ApplicationSingleton instance].conversationCache acknowledgeMessage:message];
    }
    
}

- (void)postComplete:(NSDictionary*)response {
    
    if (response != nil) {
        EnclaveResponse *enclaveResponse = [[EnclaveResponse alloc] init];
        if ([enclaveResponse processResponse:response errorDelegate:errorDelegate]) {
            NSDictionary *messageResponse = [enclaveResponse getResponse];
            if (_responseConsumer != nil) {
                [_responseConsumer response:messageResponse];
            }
            else {
                NSLog(@"MessageManager.postComplete - responseConsumer is nil");
            }
        }
    }
    
}

- (void)sendMessage:(NSString *)message withPublicId:(NSString *)publicId {

    NSMutableDictionary *contact = [contactDatabase getContact:publicId];
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
    NSMutableArray *contacts = [NSMutableArray array];
    [contacts addObject:contact];
    [contactDatabase updateContacts:contacts];

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
    sentMessage = msg;
    sentMessage[@"cleartext"] = message;
    [self sendRequest:msg];

}

- (void)sendRequest:(NSDictionary*)request {

    if (_session == nil) {
        ApplicationSingleton *app = [ApplicationSingleton instance];
        _session = app.restSession;
    }
    
    EnclaveRequest *enclaveRequest = [[EnclaveRequest alloc] init];
    [enclaveRequest setRequest:request];
    
    postPacket = enclaveRequest;
    [_session queuePost:self];
    
}

- (void)sessionComplete:(NSDictionary*)response {
    // Nothing to do here. Session is already established.
}

- (void)setResponseConsumer:(id<ResponseConsumer>)consumer {

    _responseConsumer = consumer;
    errorDelegate = _responseConsumer.errorDelegate;

}

@end
