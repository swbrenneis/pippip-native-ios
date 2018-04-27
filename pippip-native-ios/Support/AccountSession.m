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
    BOOL notificationComplete;
    ContactManager *contactManager;
    MessageManager *messageManager;
    NSDate *suspendTime;
}

@end

@implementation AccountSession

- (instancetype)init {
    self = [super init];

    sessionActive = NO;
    suspended = NO;
    notificationComplete = YES;
    // We need to create a dummy session for statup before authentication.
    SessionStateActual *actual = [[SessionStateActual alloc] init];
    actual.authenticated = NO;
    SessionState *sessionState = [[SessionState alloc] init];
    [sessionState setState:actual];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(newSession:)
                                                 name:NEW_SESSION
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(sessionEnded:)
                                                 name:SESSION_ENDED
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(requestsUpdated:)
                                                 name:REQUESTS_UPDATED
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(newMessages:)
                                                 name:NEW_MESSAGES
                                               object:nil];

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
- (void)newMessages:(NSNotification*)notification {

    dispatch_async(dispatch_get_main_queue(), ^{
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    });
    
}

- (void)newSession:(NSNotification*)notification {

    contactManager = [[ContactManager alloc] init];
    messageManager = [[MessageManager alloc] init];

    sessionActive = YES;
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
//    [messageManager getNewMessages];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self->contactManager getPendingRequests];
    });
#if TARGET_OS_SIMULATOR
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self getNewMessages];
    });
#endif

}

- (void)requestsUpdated:(NSNotification*)notification {

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

}

- (void)sessionEnded:(NSNotification*)notification {
    
    sessionActive = NO;
    [contactManager clearContacts];
    
}

- (void)resume {

    if (suspended) {
        suspended = NO;
        sessionActive = YES;
        NSDate *resumeTime = [NSDate date];
        NSInteger suspendedTime = [resumeTime timeIntervalSinceDate:suspendTime];
        if (suspendedTime > 0 && suspendedTime < 180) {     // 30 minutes
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                [self->contactManager getPendingRequests];
            });
        }

        NSInteger badgeNumber = [UIApplication sharedApplication].applicationIconBadgeNumber;
        if (badgeNumber > 0) {
            [messageManager getNewMessages];
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
        if (badgeNumber > 0) {
            [messageManager getNewMessages];
        }
    }
    completionHandler(UNNotificationPresentationOptionBadge);

}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)(void))completionHandler {

    [messageManager getNewMessages];
    completionHandler();

}

@end
