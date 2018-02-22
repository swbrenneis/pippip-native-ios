//
//  AccountSession.m
//  pippip-native-ios
//
//  Created by Steve Brenneis on 1/25/18.
//  Copyright © 2018 seComm. All rights reserved.
//

#import "AccountSession.h"
#import "ApplicationSingleton.h"
#import "EnclaveRequest.h"
#import "EnclaveResponse.h"
#import "ContactDatabase.h"
#import "LoggingErrorDelegate.h"
#import "ContactManager.h"
#import "MessageManager.h"
#import "RESTSession.h"
//#import "NSData+HexEncode.h"
#import <Realm/Realm.h>

typedef enum UPDATE { MESSAGES, CONTACTS, ACK_MESSAGES } UpdateType;

@interface AccountSession ()
{
    UpdateType updateType;
    BOOL sessionActive;
    ContactDatabase *contactDatabase;
    MessageManager *messageManager;
    ContactManager *contactManager;
    NSInteger newMessageCount;
    //NSArray *pending;
}

@property (weak, nonatomic) id<MessageObserver> messageObserver;
@property (weak, nonatomic) id<ContactObserver> contactObserver;
@property (weak, nonatomic) RESTSession *session;

@end

@implementation AccountSession

@synthesize errorDelegate;
//@synthesize postPacket;

- (instancetype)initWithRESTSession:(RESTSession *)restSession {
    self = [super init];

    _session = restSession;
    errorDelegate = [[LoggingErrorDelegate alloc] init];
    sessionActive = NO;
    _messageObserver = nil;
    _contactObserver = nil;
    contactManager = nil;
    messageManager = nil;
    contactDatabase = [[ContactDatabase alloc] init];

    return self;

}

- (void)acknowledgeMessages {

    if (newMessageCount > 0) {
        updateType = ACK_MESSAGES;
        [messageManager acknowledgePendingMessages];
    }
    else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [NSTimer scheduledTimerWithTimeInterval:2.0 repeats:NO block:^(NSTimer *timer) {
                [self updateContacts];
            }];
        });
    }

}

- (void)contactsUpdated:(NSDictionary*)response {

        NSString *error = response[@"error"];
        if (error == nil) {
            NSArray *contacts = response[@"contacts"];
            for (NSDictionary *contact in contacts) {
                [contactManager updateContact:contact];
            }
            if (contacts.count > 0 && _contactObserver != nil) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [_contactObserver contactsUpdated];
                });
            }
        }
        else {
            NSLog(@"Error response: %@", error);
        }

}

- (void)endSession {
    
    sessionActive = NO;
    /*
    contactManager = nil;
    messageManager = nil;
    contactDatabase = nil;
    messageDatabase = nil;
     */

}

-(void)messagesAcknowledged:(NSDictionary*)response {
    
    NSString *error = response[@"error"];
    if (error == nil) {
        NSArray *exceptions = response[@"exceptions"];
        NSLog(@"Messages acknowledged, %ld exceptions", exceptions.count);
        [messageManager pendingMessagesAcknowledged];
    }
    else {
        NSLog(@"Error response: %@", error);
    }
    
}

- (void)messagesUpdated:(NSDictionary*)response {

    NSString *error = response[@"error"];
    if (error == nil) {
        NSArray *messages = response[@"messages"];
        newMessageCount = messages.count;
        if (messages.count > 0) {
            [_conversationCache addMessages:messages];
            if (_messageObserver != nil) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [_messageObserver newMessagesReceived];
                });
            }
        }
    }
    else {
        NSLog(@"Error response: %@", error);
    }

}

- (void)response:(NSDictionary *)info {

    if (info != nil) {
        switch (updateType) {
            case ACK_MESSAGES:
                [self messagesAcknowledged:info];
                if (sessionActive) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [NSTimer scheduledTimerWithTimeInterval:2.0 repeats:NO block:^(NSTimer *timer) {
                            [self updateContacts];
                        }];
                    });
                }
                break;
            case CONTACTS:
                [self contactsUpdated:info];
                if (sessionActive) {
                    [self updateMessages];
                }
                break;
            case MESSAGES:
                [self messagesUpdated:info];
                if (sessionActive) {
                    [self acknowledgeMessages];
                }
                break;
        }
    }

}

/*
- (void)sendRequest:(NSDictionary*)request {
    
    EnclaveRequest *enclaveRequest = [[EnclaveRequest alloc] initWithState:_sessionState];
    [enclaveRequest setRequest:request];
    
    postPacket = enclaveRequest;
    [_session queuePost:self];
    
}

- (void)sessionComplete:(NSDictionary*)response {
    // Nothing to do here.
}
*/
- (void)setContactObserver:(id<ContactObserver>)observer {
    _contactObserver = observer;
}

- (void)setMessageObserver:(id<MessageObserver>)observer {
    _messageObserver = observer;
}

- (void)startSession:(SessionState *)state {

    _sessionState = state;
    if (contactManager == nil) {
        contactManager = [[ContactManager alloc] init];
        [contactManager setResponseConsumer:self];
        messageManager = [[MessageManager alloc] init];
        [messageManager setResponseConsumer:self];
    }
    else {
        [contactManager startNewSession:state];
        [messageManager startNewSession:state];
    }
    [_conversationCache startNewSession:state];
    sessionActive = YES;
    dispatch_async(dispatch_get_main_queue(), ^{
        [NSTimer scheduledTimerWithTimeInterval:2.0 repeats:NO block:^(NSTimer *timer) {
            [self updateContacts];
        }];
    });
    
}

- (void)unsetMessageObserver:(id<MessageObserver>)observer {
    
    if (_messageObserver == observer) {
        _messageObserver = nil;
    }

}

- (void)unsetContactObserver:(id<ContactObserver>)observer {

    if (_contactObserver == observer) {
        _contactObserver = nil;
    }

}

- (void)updateContacts {

    if (sessionActive) {
        updateType = CONTACTS;
        if ([contactManager updatePendingContacts] == 0) {
            // No contacts updated, go directly to update messages.
            [self updateMessages];
        }
    }

}

- (void)updateMessages {

    updateType = MESSAGES;
    NSLog(@"%@", @"Retrieving new messages");
    newMessageCount = 0;
    [messageManager getNewMessages];

}

@end
