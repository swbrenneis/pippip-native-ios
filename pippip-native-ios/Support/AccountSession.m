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
#import "EnclaveRequest.h"
#import "EnclaveResponse.h"
#import "ContactDatabase.h"
#import "LoggingErrorDelegate.h"
#import "ContactManager.h"
#import "Notifications.h"
#import "Notifications.h"

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
    contactManager = [[ContactManager alloc] init];
    messageManager = [[MessageManager alloc] init];

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

    return self;

}

- (void)newSession:(NSNotification*)notification {
    
    sessionActive = YES;
    dispatch_async(dispatch_get_main_queue(), ^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [contactManager getRequests];
        });
    });
    
}

- (void)requestsUpdated:(NSNotification*)notification {

    if (sessionActive) {
        [contactManager updatePendingContacts];
        dispatch_async(dispatch_get_main_queue(), ^{
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 15 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                [contactManager getRequests];
            });
        });
    }

}

- (void)sessionEnded:(NSNotification*)notification {
    
    sessionActive = NO;
    
}

- (void)resume {

    if (suspended) {
        suspended = NO;
        sessionActive = YES;
        NSDate *resumeTime = [NSDate date];
        NSInteger suspendedTime = [resumeTime timeIntervalSinceDate:suspendTime];
        if (suspendedTime > 0 && suspendedTime < 180) {     // 30 minutes
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                [contactManager getRequests];
            });
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

    if (sessionActive && notificationComplete) {
        NSInteger messageCount = [notification.request.content.badge integerValue];
        if (messageCount > 0) {
            notificationComplete = NO;
            [messageManager getNewMessages];
        }
    }
    completionHandler(UNNotificationPresentationOptionBadge);

}

@end
