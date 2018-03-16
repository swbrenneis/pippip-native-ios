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

typedef enum UPDATE { MESSAGES, CONTACTS, ACK_MESSAGES , NONE } UpdateType;

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
    _simulator = NO;

    return self;

}

- (void)acknowledgeMessages {

    if (newMessageCount > 0) {
        updateType = ACK_MESSAGES;
        [messageManager acknowledgePendingMessages];
    }
    else {
        updateType = NONE;
    }
//    else {
//        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//            [NSTimer scheduledTimerWithTimeInterval:2.0 repeats:NO block:^(NSTimer *timer) {
//                [self updateContacts];
//            }];
//        });
//    }

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
        dispatch_async(dispatch_get_main_queue(), ^{
            [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
        });
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
        if (newMessageCount > 0) {
            [_conversationCache addNewMessages:messages];
            dispatch_async(dispatch_get_main_queue(), ^{
                NSMutableDictionary *messageCount = [NSMutableDictionary dictionary];
                messageCount[@"count"] = [NSNumber numberWithInteger:newMessageCount];
                [[NSNotificationCenter defaultCenter]
                 postNotificationName:@"MessagesUpdated" object:nil userInfo:messageCount];
            });
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
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
//                if (sessionActive) {
//                    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//                        [NSTimer scheduledTimerWithTimeInterval:2.0 repeats:NO block:^(NSTimer *timer) {
//                            [self updateContacts];
//                        }];
//                    });
//               }
                break;
            case CONTACTS:
                [self contactsUpdated:info];
#if TARGET_OS_SIMULATOR
                if (sessionActive) {
                    [self updateMessages];
                }
#endif
                break;
            case MESSAGES:
                [self messagesUpdated:info];
                if (sessionActive) {
                    [self acknowledgeMessages];
                }
                break;
            case NONE:
                break;
        }
    }

}

- (void)resume {

    NSDate *resumeTime = [NSDate date];
    if ([resumeTime timeIntervalSinceDate:suspendTime] < 180) {     // 30 minutes
        sessionActive = YES;
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [NSTimer scheduledTimerWithTimeInterval:30.0 repeats:NO block:^(NSTimer *timer) {
                [self updateContacts];
            }];
        });
    }

}

- (void)runSession {

    while (sessionActive) {
        [NSThread sleepForTimeInterval:2.0];
        [self updateContacts];
    }

}

- (void)startSession:(SessionState *)state {

    _sessionState = state;
    sessionActive = YES;
    dispatch_async(dispatch_get_main_queue(), ^{
        NSInteger count = [UIApplication sharedApplication].applicationIconBadgeNumber;
        if (count > 0) {
            [self updateMessages];
        }
    });

#if TARGET_OS_SIMULATOR
    float interval = 2.0;
#else
    float interval = 30.0;
#endif
    [self updateContacts];
    [NSThread detachNewThreadWithBlock:^{
        while (sessionActive) {
            [NSThread sleepForTimeInterval:interval];
            [self updateContacts];
        }
    }];

}

- (void)suspend {

    sessionActive = NO;
    suspendTime = [NSDate date];

}

- (void)updateContacts {

    if (sessionActive) {
        updateType = CONTACTS;
#if TARGET_OS_SIMULATOR
        if ([contactManager updatePendingContacts] == 0) {
            // No contacts updated, go directly to update messages.
            [self updateMessages];
        }
#else
        [contactManager updatePendingContacts];
#endif
    }

}

- (void)updateMessages {

    updateType = MESSAGES;
    newMessageCount = 0;
    [messageManager getNewMessages];

}

#pragma Mark - Notification center delegate

- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler {

    NSInteger messageCount = [notification.request.content.badge integerValue];
    if (messageCount > 0) {
        [self updateMessages];
    }
    completionHandler(UNNotificationPresentationOptionBadge);

}

@end
