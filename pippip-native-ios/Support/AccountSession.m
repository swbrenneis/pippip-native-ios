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
    return self;

}

- (void)doUpdates {

    notificationComplete = NO;
    [messageManager getNewMessages];
    [contactManager getPendingRequests];
    [contactManager getRequestStatusWithRetry:NO publicId:nil];
    notificationComplete = YES;
    dispatch_async(dispatch_get_main_queue(), ^{
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    });
/*
#if TARGET_OS_SIMULATOR
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 5 * NSEC_PER_SEC),
                   dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0), ^{
                       if (self->sessionActive) {
                           [self doUpdates];
                       }
    });
#endif
*/
}

- (void)newSession:(NSNotification*)notification {

    contactManager = [[ContactManager alloc] init];
    messageManager = [[MessageManager alloc] init];

    sessionActive = YES;

    // Give everything time to get set up.
    /*
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 5 * NSEC_PER_SEC),
                   dispatch_get_main_queue(), ^{
                       if ([UIApplication sharedApplication].applicationIconBadgeNumber > 0) {
                           [self doUpdates];
                       }
                   });
*/
}

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
/*
        if (suspendedTime > 0 && suspendedTime < LocalAuthenticator.sessionTTL) {
            if (notificationComplete) {
                [self doUpdates];
            }
        }
 */
        NSMutableDictionary *info = [NSMutableDictionary dictionary];
        info[@"suspendedTime"] = [NSNumber numberWithInteger:suspendedTime];
        [AsyncNotifier notifyWithName:APP_RESUMED object:nil userInfo:info];
    }

}

- (void)suspend {

    sessionActive = NO;
    suspended = YES;
    suspendTime = [NSDate date];
    [AsyncNotifier notifyWithName:APP_SUSPENDED object:nil userInfo:nil];

}

#pragma Mark - Notification center delegate

- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler {

    if (sessionActive) {
        if (notificationComplete) {
            [self doUpdates];
        }
    }
    completionHandler(UNNotificationPresentationOptionBadge);

}

@end
