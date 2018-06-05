//
//  AccountSession.h
//  pippip-native-ios
//
//  Created by Steve Brenneis on 1/25/18.
//  Copyright © 2018 seComm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UserNotifications/UserNotifications.h>

@interface AccountSession : NSObject <UNUserNotificationCenterDelegate>

@property (nonatomic) NSData *_Nullable deviceToken;

- (void)doUpdates;

- (void)resume;

- (void)suspend;

@end
