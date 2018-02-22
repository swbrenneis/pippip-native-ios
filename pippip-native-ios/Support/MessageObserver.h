//
//  MessageObserver.h
//  pippip-native-ios
//
//  Created by Steve Brenneis on 2/16/18.
//  Copyright © 2018 seComm. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MessageObserver <NSObject>

@optional
- (void)newMessage:(NSDictionary*)message;

- (void)newMessagesReceived;

@end

