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
//#import "MessageManager.h"
#import "Notifications.h"
#import "Notifications.h"

typedef enum UPDATE { MESSAGES, CONTACTS, ACK_MESSAGES , NONE } UpdateType;

@interface AccountSession ()
{
    UpdateType updateType;
    BOOL sessionActive;
    //MessageManager *messageManager;
    ContactManager *contactManager;
    NSInteger newMessageCount;
    NSDate *suspendTime;
    BOOL notificationComplete;
    BOOL suspended;
}

@end

@implementation AccountSession

- (instancetype)init {
    self = [super init];

    sessionActive = NO;
    contactManager = [[ContactManager alloc] init];
    //messageManager = [[MessageManager alloc] init];
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
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(contactsUpdated:)
                                                 name: CONTACTS_UPDATED
                                               object:nil];

    return self;

}

- (void)acknowledgeMessages {
/*
    if (newMessageCount > 0) {
        updateType = ACK_MESSAGES;
        [messageManager acknowledgePendingMessages];
    }
    else {
        updateType = NONE;
    }
*/
}

- (void)contactsUpdated:(NSNotification*)notification {
/*
#if TARGET_OS_SIMULATOR
    [messageManager getNewMessages];
#endif
*/
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 15 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [contactManager updatePendingContacts];
    });

}

- (void)messagesUpdated:(NSNotification*)notification {
}

- (void)newSession:(NSNotification*)notification {
    
    sessionActive = YES;
    dispatch_async(dispatch_get_main_queue(), ^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [contactManager updatePendingContacts];
        });
    });
    
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
/*
    updateType = MESSAGES;
    newMessageCount = 0;
    [messageManager getNewMessages];
*/
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
