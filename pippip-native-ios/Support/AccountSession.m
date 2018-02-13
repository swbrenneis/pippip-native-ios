//
//  AccountSession.m
//  pippip-native-ios
//
//  Created by Steve Brenneis on 1/25/18.
//  Copyright © 2018 seComm. All rights reserved.
//

#import "AccountSession.h"
#import "EnclaveRequest.h"
#import "EnclaveResponse.h"
#import "ContactDatabase.h"
#import "LoggingErrorDelegate.h"
#import "NSData+HexEncode.h"
#import <Realm/Realm.h>

typedef enum UPDATE { MESSAGES, CONTACTS, ACK_MESSAGES } UpdateType;

@interface AccountSession ()
{
    UpdateType updateType;
    BOOL sessionActive;
    NSMutableArray *pendingMessages;
    NSArray *exceptions;
    ContactDatabase *contactDatabase;
}

@property (weak, nonatomic) RESTSession *session;

@end

@implementation AccountSession

@synthesize errorDelegate;
@synthesize postPacket;

- (instancetype)initWithRESTSession:(RESTSession*)restSession {
    self = [super init];

    _session = restSession;
    _contactManager = [[ContactManager alloc] initWithRESTSession:restSession];
    _messageManager = [[MessageManager alloc] initWithRESTSession:restSession];
    errorDelegate = [[LoggingErrorDelegate alloc] init];
    pendingMessages = [NSMutableArray array];
    sessionActive = NO;

    return self;

}

- (void)acknowledgeMessages {

    updateType = ACK_MESSAGES;

    // Get pending messages from the message manager
    if (_messageManager.pendingMessages.count > 0) {
        NSMutableArray *pending = [NSMutableArray arrayWithArray:_messageManager.pendingMessages];
        [_messageManager.pendingMessages removeAllObjects];
        // Add them to the pending queue
        for (NSDictionary *message in pending) {
            [pendingMessages addObject:message];
        }
    }
    if (pendingMessages.count > 0) {
        NSLog(@"%@", @"Acknowledging messages");
        NSMutableDictionary *request = [NSMutableDictionary dictionary];
        request[@"method"] = @"AcknowledgeMessages";
        NSMutableArray *messages = [NSMutableArray array];
        for (NSDictionary *msg in pendingMessages) {
            NSMutableDictionary *message = [NSMutableDictionary dictionary];
            message[@"toId"] = msg[@"publicId"];
            message[@"sequence"] = msg[@"sequence"];
            message[@"timestamp"] = msg[@"timestamp"];
            [messages addObject:message];
        }
        request[@"messages"] = messages;
        [self sendRequest:request];
    }

}

- (void)contactsUpdated:(NSDictionary*)response {

    if (response != nil) {
        NSString *error = response[@"error"];
        if (error == nil) {
            NSDictionary *updateResponse = [self getEnclaveResponse:response];
            NSArray *contacts = updateResponse[@"contacts"];
            for (NSDictionary *contact in contacts) {
                [self processContact:contact];
            }
        }
        else {
            NSLog(@"Error response: %@", error);
        }
    }

}

- (void)endSession {
    
    sessionActive = NO;
    //[_contactManager endSession];
    [_messageManager endSession];

}

- (NSDictionary*)getEnclaveResponse:(NSDictionary*)encoded {

    EnclaveResponse *enclaveResponse = [[EnclaveResponse alloc] initWithState:_sessionState];
    if ([enclaveResponse processResponse:encoded errorDelegate:errorDelegate]) {
        NSDictionary *updateResponse = [enclaveResponse getResponse];
        NSError *error = updateResponse[@"error"];
        if (error == nil) {
            return [enclaveResponse getResponse];
        }
        else {
            NSLog(@"Error response: %@", error);
        }
    }
    return nil;

}

- (void)messagesUpdated:(NSDictionary*)response {

    if (response != nil) {
        NSString *error = response[@"error"];
        if (error == nil) {
            NSDictionary *updateResponse = [self getEnclaveResponse:response];
            NSArray *messages = updateResponse[@"messages"];
            [_messageManager addReceivedMessages:messages];
        }
        else {
            NSLog(@"Error response: %@", error);
        }
    }

}

-(void)messagesAcknowledged:(NSDictionary*)response {

    if (response != nil) {
        exceptions = response[@"exceptions"];
        NSLog(@"Messages acknowledged, %ld exceptions", exceptions.count);
        [pendingMessages removeAllObjects];
    }

}

- (void)postComplete:(NSDictionary*)response {

    switch (updateType) {
        case ACK_MESSAGES:
            [self messagesAcknowledged:response];
            if (sessionActive) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [NSTimer scheduledTimerWithTimeInterval:2.0 repeats:NO block:^(NSTimer *timer) {
                        [self updateContacts];
                    }];
                });
            }
            break;
        case CONTACTS:
            [self contactsUpdated:response];
            if (sessionActive) {
                [self updateMessages];
            }
            break;
        case MESSAGES:
            [self messagesUpdated:response];
            if (sessionActive) {
                [self acknowledgeMessages];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [NSTimer scheduledTimerWithTimeInterval:2.0 repeats:NO block:^(NSTimer *timer) {
                        [self updateContacts];
                    }];
                });
            }
            break;
    }

}

- (void)processContact:(NSDictionary*)contact {

    NSString *publicId = contact[@"publicId"];
    NSDictionary *entity = [contactDatabase getContact:publicId];
    if (entity == nil) {
        // Something really wrong here
        NSLog(@"Process contact, contact %@ does not exist", publicId);
    }
    else {
        NSMutableDictionary *update = [entity mutableCopy];
        NSString *status = contact[@"status"];
        update[@"status"] = status;
        update[@"timestamp"] = contact[@"timestamp"];
        if ([status isEqualToString:@"accepted"]) {
            update[@"currentSequence"] = [NSNumber numberWithLong:0L];
            update[@"currentIndex"] = [NSNumber numberWithLong:0L];
            NSData *authData = [[NSData alloc] initWithBase64EncodedString:contact[@"authData"] options:0];
            update[@"authData"] = authData;
            NSData *nonce = [[NSData alloc] initWithBase64EncodedString:contact[@"nonce"] options:0];
            update[@"nonce"] = nonce;
            NSArray *messageKeys = contact[@"messageKeys"];
            NSMutableArray *keys = [NSMutableArray array];
            for (NSString *keyString in messageKeys) {
                NSData *key = [[NSData alloc] initWithBase64EncodedString:keyString options:0];
                [keys addObject:key];
            }
            update[@"messageKeys"] = keys;
        }
        [contactDatabase updateContact:update];
    }

}

- (void)sendRequest:(NSDictionary*)request {
    
    EnclaveRequest *enclaveRequest = [[EnclaveRequest alloc] initWithState:_sessionState];
    [enclaveRequest setRequest:request];
    
    postPacket = enclaveRequest;
    [_session queuePost:self];
    
}

- (void)sessionComplete:(NSDictionary*)response {
    // Nothing to do here.
}

/*
 * This is invoked from the main thread.
 */
- (void)startSession:(SessionState *)state {

    _sessionState = state;
    [_contactManager setSessionState:state];
    [_messageManager setSessionState:state];
    contactDatabase = [[ContactDatabase alloc] initWithSessionState:state];
    sessionActive = YES;
    [NSTimer scheduledTimerWithTimeInterval:2.0 repeats:NO block:^(NSTimer *timer) {
        [self updateContacts];
    }];
    
}

- (void)updateContacts {

    if (sessionActive) {
        NSArray *pending = [_contactManager getPendingContactIds];
        if (pending.count > 0) {
            NSLog(@"%@", @"Updating pending contacts");
            NSMutableDictionary *request = [NSMutableDictionary dictionary];
            request[@"method"] = @"UpdatePendingContacts";
            request[@"pending"] = pending;
            updateType = CONTACTS;
            [self sendRequest:request];
        }
        else {
            [self updateMessages];
        }
    }

}

- (void)updateMessages {

    NSLog(@"%@", @"Retrieving new messages");
    NSMutableDictionary *request = [NSMutableDictionary dictionary];
    request[@"method"] = @"GetMessages";
    updateType = MESSAGES;
    [self sendRequest:request];

}

@end
