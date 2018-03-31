////
//  AccountSession.m
//  pippip-native-ios
//
//  Created by Steve Brenneis on 1/25/18.
//  Copyright © 2018 seComm. All rights reserved.
//

#import "AccountSession.h"
#import "pippip_native_ios-Swift.h"
#import "ApplicationSingleton.h"
#import "EnclaveRequest.h"
#import "EnclaveResponse.h"
#import "ContactDatabase.h"
#import "LoggingErrorDelegate.h"
#import "ContactManager.h"
#import "MessageManager.h"
#import "RESTSession.h"
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
    BOOL notificationComplete;
    BOOL suspended;
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
    //[contactManager setResponseConsumer:self];
    messageManager = [[MessageManager alloc] init];
    [messageManager setResponseConsumer:self];
    contactDatabase = [[ContactDatabase alloc] init];
    notificationComplete = YES;
    suspended = NO;

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(newSession:)
                                                 name:@"NewSession"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(sessionEnded:)
                                                 name:@"SessionEnded"
                                               object:nil];

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

}

- (void)contactsUpdated:(NSDictionary*)response {

    NSString *error = response[@"error"];
    if (error == nil) {
        NSArray *contacts = response[@"contacts"];
        NSLog(@"%ld contacts updated", contacts.count);
        [contactManager updateContacts:contacts];
    }
    else {
        NSLog(@"Error response: %@", error);
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 15 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self updateContacts];
    });

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
    notificationComplete = YES;
#if TARGET_OS_SIMULATOR
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self updateContacts];
    });
#endif

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
    }
    else {
        NSLog(@"Error response: %@", error);
    }

}

- (void)newSession:(NSNotification*)notification {
    
    //_sessionState = state;
    sessionActive = YES;
#if TARGET_OS_SIMULATOR
    [self updateContacts];
#else
    dispatch_async(dispatch_get_main_queue(), ^{
        NSInteger count = [UIApplication sharedApplication].applicationIconBadgeNumber;
        if (count > 0) {
            [self updateMessages];
        }
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [self updateContacts];
        });
    });
#endif
    
}

- (void)response:(NSDictionary *)info {

    if (info != nil) {
        switch (updateType) {
            case ACK_MESSAGES:
                [self messagesAcknowledged:info];
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
#if TARGET_OS_SIMULATOR
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                        // [self updateContacts];
                    });
#endif
                }
                break;
            case NONE:
                break;
        }
    }

}

- (void)resume {

    if (suspended) {
        suspended = NO;
        NSDate *resumeTime = [NSDate date];
        NSInteger suspendedTime = [resumeTime timeIntervalSinceDate:suspendTime];
        if (suspendedTime > 0 && suspendedTime < 180) {     // 30 minutes
            sessionActive = YES;
            NSInteger count = [UIApplication sharedApplication].applicationIconBadgeNumber;
            if (count > 0) {
                [self updateMessages];
            }
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                [self updateContacts];
            });
        }
        NSMutableDictionary *info = [NSMutableDictionary dictionary];
        info[@"suspendedTime"] = [NSNumber numberWithInteger:suspendedTime];
        [AsyncNotifier notifyWithName:@"AppResumed" object:nil userInfo:info];
    }

}

- (void)runSession {

    while (sessionActive) {
        [NSThread sleepForTimeInterval:2.0];
        [self updateContacts];
    }

}

- (void)sessionEnded:(NSNotification*)notification {
    
    sessionActive = NO;
    
}

- (void)suspend {

    sessionActive = NO;
    suspended = YES;
    suspendTime = [NSDate date];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"AppSuspended" object:nil];

}

- (void)updateContacts {

    updateType = CONTACTS;
    if (sessionActive) {
        if ([contactManager updatePendingContacts] == 0) {
#if TARGET_OS_SIMULATOR
            [self updateMessages];
#else
            NSLog(@"No pending contacts, scheduling next update");
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 15 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                [self updateContacts];
            });
#endif
        }
    }

}

- (void)updateMessages {

    updateType = MESSAGES;
    newMessageCount = 0;
    [messageManager getNewMessages];

}

#pragma Mark - Notification center delegate

- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler {

    if (sessionActive && notificationComplete) {
        NSInteger messageCount = [notification.request.content.badge integerValue];
        if (messageCount > 0) {
            notificationComplete = NO;
            [self updateMessages];
        }
    }
    completionHandler(UNNotificationPresentationOptionBadge);

}

@end
