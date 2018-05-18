////
//  AccountSession.m
//  pippip-native-ios
//
//  Created by Steve Brenneis on 1/25/18.
//  Copyright © 2018 seComm. All rights reserved.
//

#import "pippip_native_ios-Swift.h"

#import "AccountSession.h"
#import "ApplicationSingleton.h"
#import "Notifications.h"
#import "MessagesDatabase.h"

@interface AccountSession ()
{
    BOOL sessionActive;
    BOOL suspended;
    ContactManager *contactManager;
    MessageManager *messageManager;
    NSDate *suspendTime;
    BOOL notificationComplete;
}

@end

@implementation AccountSession

- (instancetype)init {
    self = [super init];

    sessionActive = NO;
    suspended = NO;
    notificationComplete = YES;

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(newSession:)
                                                 name:NEW_SESSION
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(sessionEnded:)
                                                 name:SESSION_ENDED
                                               object:nil];
    /*
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(requestsUpdated:)
                                                 name:REQUESTS_UPDATED
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(newMessages:)
                                                 name:NEW_MESSAGES
                                               object:nil];
*/
    return self;

}

#if TARGET_OS_SIMULATOR
- (void)getNewMessages {

    if (sessionActive) {
        [messageManager getNewMessages];
        if (sessionActive) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                [self getNewMessages];
            });
        }
    }

}
#endif
/*
- (void)newMessages:(NSNotification*)notification {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSInteger badgeCount = [UIApplication sharedApplication].applicationIconBadgeNumber;
        NSInteger messageCount = [(NSNumber*)notification.object integerValue];
        NSInteger newBadgeCount = badgeCount - messageCount;
        if (newBadgeCount < 0) {
            newBadgeCount = 0;
        }
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:newBadgeCount];
    });
    notificationComplete = YES;

}
*/
- (void)newSession:(NSNotification*)notification {

    contactManager = [[ContactManager alloc] init];
    messageManager = [[MessageManager alloc] init];

    sessionActive = YES;

    if (notificationComplete && [UIApplication sharedApplication].applicationIconBadgeNumber > 0) {
        notificationComplete = NO;
        [messageManager getNewMessages];
        [contactManager getPendingRequests];
        [contactManager updatePendingContacts];
        notificationComplete = YES;
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    }
/*
#if TARGET_OS_SIMULATOR
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self getNewMessages];
    });
#endif
*/

}
/*
- (void)requestsUpdated:(NSNotification*)notification {

    dispatch_async(dispatch_get_main_queue(), ^{
        NSInteger badgeCount = [UIApplication sharedApplication].applicationIconBadgeNumber;
        NSInteger requestCount = [(NSNumber*)notification.object integerValue];
        NSInteger newBadgeCount = badgeCount - requestCount;
        if (newBadgeCount < 0) {
            newBadgeCount = 0;
        }
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:newBadgeCount];
    });
    notificationComplete = YES;

#if TARGET_OS_SIMULATOR
    if (sessionActive) {
        [contactManager updatePendingContacts];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 15 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                if (self->sessionActive) {
                    [self->contactManager getPendingRequests];
                }
            });
        });
#endif
}
*/
- (void)sessionEnded:(NSNotification*)notification {

    sessionActive = NO;
    [contactManager clearContacts];
    [ConversationCache clearCache];
    
}

- (void)resume {

    if (suspended) {
        suspended = NO;
        sessionActive = YES;
        NSDate *resumeTime = [NSDate date];
        NSInteger suspendedTime = [resumeTime timeIntervalSinceDate:suspendTime];

        if (suspendedTime > 0 && suspendedTime < LocalAuthenticator.sessionTTL) {
            NSInteger badgeNumber = [UIApplication sharedApplication].applicationIconBadgeNumber;
            if (notificationComplete && badgeNumber > 0) {
                notificationComplete = NO;
                [messageManager getNewMessages];
                [contactManager getPendingRequests];
                [contactManager updatePendingContacts];
                notificationComplete = YES;
                [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
            }
        }
        NSMutableDictionary *info = [NSMutableDictionary dictionary];
        info[@"suspendedTime"] = [NSNumber numberWithInteger:suspendedTime];
        [AsyncNotifier notifyWithName:APP_RESUMED object:nil userInfo:info];
    }

}

- (void)suspend {

    sessionActive = NO;
    suspended = YES;
    suspendTime = [NSDate date];
    [[NSNotificationCenter defaultCenter] postNotificationName:APP_SUSPENDED object:nil];

}

#pragma Mark - Notification center delegate

- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler {

    if (sessionActive) {
        NSInteger badgeNumber = [notification.request.content.badge integerValue];
        if (notificationComplete && badgeNumber > 0) {
            notificationComplete = NO;
            [messageManager getNewMessages];
            [contactManager getPendingRequests];
            [contactManager updatePendingContacts];
            notificationComplete = YES;
            [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
        }
    }
    completionHandler(UNNotificationPresentationOptionBadge);

}
/*
- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)(void))completionHandler {

    [messageManager getNewMessages];
    completionHandler();

}
*/
@end
