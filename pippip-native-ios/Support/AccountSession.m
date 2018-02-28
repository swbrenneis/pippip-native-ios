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
    NSDate *suspendTime;
}

@property (weak, nonatomic) RESTSession *session;

@end

@implementation AccountSession

@synthesize errorDelegate;
//@synthesize postPacket;

- (instancetype)init {
    self = [super init];

    errorDelegate = [[LoggingErrorDelegate alloc] init];
    sessionActive = NO;
    contactManager = [[ContactManager alloc] init];
    [contactManager setResponseConsumer:self];
    messageManager = [[MessageManager alloc] init];
    [messageManager setResponseConsumer:self];
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
            NSLog(@"%ld contacts updated", contacts.count);
            for (NSDictionary *contact in contacts) {
                [contactManager updateContact:contact];
            }
            if (contacts.count > 0) {
                [[NSNotificationCenter defaultCenter]
                        postNotification:[NSNotification notificationWithName:@"ContactsUpdated" object:nil]];
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
        NSLog(@"Messages update, %ld messages", newMessageCount);
        if (messages.count > 0) {
            [_conversationCache addMessages:messages];
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter]
                    postNotification:[NSNotification notificationWithName:@"NewMessagesReceived" object:nil]];
            });
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

- (void)resume {

    NSDate *resumeTime = [NSDate date];
    if ([resumeTime timeIntervalSinceDate:suspendTime] < 180) {     // 30 minutes
        sessionActive = YES;
        dispatch_async(dispatch_get_main_queue(), ^{
            [NSTimer scheduledTimerWithTimeInterval:2.0 repeats:NO block:^(NSTimer *timer) {
                [self updateContacts];
            }];
        });
    }

}

- (void)startSession:(SessionState *)state {

    _sessionState = state;
    sessionActive = YES;
    dispatch_async(dispatch_get_main_queue(), ^{
        [NSTimer scheduledTimerWithTimeInterval:2.0 repeats:NO block:^(NSTimer *timer) {
            [self updateContacts];
        }];
    });
    
}

- (void)suspend {

    sessionActive = NO;
    suspendTime = [NSDate date];

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
    newMessageCount = 0;
    [messageManager getNewMessages];

}

@end
