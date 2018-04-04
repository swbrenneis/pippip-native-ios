//
//  AccountSession.h
//  pippip-native-ios
//
//  Created by Steve Brenneis on 1/25/18.
//  Copyright © 2018 seComm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UserNotifications/UserNotifications.h>

@class SessionState;

@interface AccountSession : NSObject <UNUserNotificationCenterDelegate>

@property (nonatomic) SessionState *sessionState;
@property (nonatomic) NSData *deviceToken;

//- (void)endSession;

- (void)resume;

- (void)suspend;

//- (void)startSession:(SessionState*)state;

@end
