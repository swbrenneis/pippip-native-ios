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
#import "LoggingErrorDelegate.h"
#import "NSData+HexEncode.h"

typedef enum UPDATE { MESSAGES, CONTACTS } UpdateType;

@interface AccountSession ()
{
    UpdateType updateType;
    BOOL sessionActive;
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
    sessionActive = NO;

    return self;

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
            if (contacts.count > 0) {
                [_contactManager contactsUpdated];
            }
        }
        else {
            NSLog(@"Error response: %@", error);
        }
    }

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

- (void)endSession {

    sessionActive = NO;

}

- (void)messagesUpdated:(NSDictionary*)response {

    if (response != nil) {
        NSString *error = response[@"error"];
        if (error == nil) {
            NSDictionary *updateResponse = [self getEnclaveResponse:response];
            NSArray *messages = updateResponse[@"messages"];
            [_contactManager addNewMessages:messages];
        }
        else {
            NSLog(@"Error response: %@", error);
        }
    }

}

- (void)postComplete:(NSDictionary*)response {

    switch (updateType) {
        case CONTACTS:
            [self contactsUpdated:response];
            if (sessionActive) {
                [self updateMessages];
            }
            break;
        case MESSAGES:
            [self messagesUpdated:response];
            if (sessionActive) {
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
    NSMutableDictionary *entity = [_contactManager getContact:publicId];
    if (entity == nil) {
        // Something really wrong here
        NSLog(@"Contact %@ does not exist", publicId);
    }
    else {
        // This updates the actual contact in the database
        // We just need to store the contacts after doing this.
        NSString *status = contact[@"status"];
        entity[@"status"] = status;
        entity[@"timestamp"] = contact[@"timestamp"];
        if ([status isEqualToString:@"accepted"]) {
            entity[@"currentSequence"] = [NSNumber numberWithLong:0L];
            entity[@"currentIndex"] = [NSNumber numberWithLong:0L];
            NSData *authData = [[NSData alloc] initWithBase64EncodedString:contact[@"authData"] options:0];
            entity[@"authData"] = authData;
            NSData *nonce = [[NSData alloc] initWithBase64EncodedString:contact[@"nonce"] options:0];
            entity[@"nonce"] = nonce;
            NSArray *messageKeys = contact[@"messageKeys"];
            NSMutableArray *keys = [NSMutableArray array];
            for (NSString *keyString in messageKeys) {
                NSData *key = [[NSData alloc] initWithBase64EncodedString:keyString options:0];
                [keys addObject:key];
            }
            entity[@"messageKeys"] = keys;
        }
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
    sessionActive = YES;
    [NSTimer scheduledTimerWithTimeInterval:2.0 repeats:NO block:^(NSTimer *timer) {
        [self updateContacts];
    }];
    
}

- (void)updateContacts {

    if (sessionActive) {
        NSArray *pending = [_contactManager getPendingContacts];
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
