//
//  NotificationErrorDelegate.h
//  pippip-native-ios
//
//  Created by Steve Brenneis on 3/21/18.
//  Copyright © 2018 seComm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ErrorDelegate.h"

@interface NotificationErrorDelegate : NSObject <ErrorDelegate>

- (instancetype)initWithTitle:(NSString*)title;

@end
