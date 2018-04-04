//
//  MessageManager.m
//  pippip-native-ios
//
//  Created by Steve Brenneis on 1/29/18.
//  Copyright © 2018 seComm. All rights reserved.
//

#import "MessageManager.h"
#import "pippip_native_ios-Swift.h"
#import "ApplicationSingleton.h"
#import "ConversationCache.h"
#import "ContactManager.h"
#import "EnclaveRequest.h"
#import "EnclaveResponse.h"
#import "MessagesDatabase.h"
#import "CKIVGenerator.h"
#import "CKGCMCodec.h"

@interface MessageManager ()
{
    ContactManager *contactManager;
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
    contactManager = [[ContactManager alloc] init];
    messageDatabase = [[MessagesDatabase alloc] init];
//    _conversationCache = nil;

//    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(newSession:) name:@"NewSession" object:nil];

    return self;
    
}

- (void)acknowledgePendingMessages {

    pendingMessages = [messageDatabase pendingMessageInfo];
    NSMutableDictionary *request = [NSMutableDictionary dictionary];
    request[@"method"] = @"AcknowledgeMessages";
    NSMutableArray *triplets = [NSMutableArray array];
    for (NSDictionary *info in pendingMessages) {
        NSMutableDictionary *triplet = [NSMutableDictionary dictionary];
        triplet[@"publicId"] = info[@"publicId"];
        triplet[@"sequence"] = info[@"sequence"];
        triplet[@"timestamp"] = info[@"timestamp"];
        [triplets addObject:triplet];
    }
    request[@"messages"] = triplets;
    [self sendRequest:request];

}

- (TextMessage*)getMessage:(NSInteger)messageId {

    return [messageDatabase loadMessage:messageId];

}

- (NSArray*)getMessageIds:(NSString*)publicId {

    NSInteger contactId = [[ApplicationSingleton instance].config getContactId:publicId];
    return [messageDatabase loadMessageIds:contactId];

}

- (NSArray*)getMostRecentMessages {

    NSMutableArray *recent = [NSMutableArray array];
    NSArray *contactIds = [[ApplicationSingleton instance].config allContactIds];
    for (NSNumber *contactId in contactIds) {
        [recent addObject:[messageDatabase mostRecentMessage:[contactId integerValue]]];
    }
    return recent;

}

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
        Contact *contact = [contactManager getContact:sentMessage[@"toId"]];
        sentMessage[@"contactId"] = [NSNumber numberWithInteger:contact.contactId];
        if (contact.nickname != nil) {
            sentMessage[@"nickname"] = contact.nickname;
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

    Contact *contact = [contactManager getContact:publicId];
    NSInteger sequence = contact.currentSequence + 1;
    contact.currentSequence = sequence;
    NSInteger keyIndex = contact.currentIndex + 1;
    if (keyIndex > 9) {
        keyIndex = 0;
    }
    contact.currentIndex = keyIndex;
    NSData *key = contact.messageKeys[keyIndex];
    NSMutableArray *contacts = [NSMutableArray array];
    [contacts addObject:contact];
    [contactManager updateContacts:contacts];

    // Encrypt the message.
    CKIVGenerator *ivGen = [[CKIVGenerator alloc] init];
    NSData *iv = [ivGen generate:sequence withNonce:contact.nonce];
    CKGCMCodec *codec = [[CKGCMCodec alloc] init];
    [codec setIV:iv];
    [codec putString:message];
    NSError *error = nil;
    NSData *encoded = [codec encrypt:key withAuthData:contact.authData withError:&error];
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
