//
//  AccountFinishStep.h
//  pippip-native-ios
//
//  Created by Steve Brenneis on 10/25/17.
//  Copyright © 2017 seComm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RequestStep.h"

@interface AccountFinishStep : NSObject <RequestStep>

@property (nonatomic, readonly) id<ErrorDelegate> errorDelegate;
@property (nonatomic, readonly) id<PostPacket> postPacket;
@property (nonatomic, readonly) id<RESTResponse> response;

- (instancetype)initWithState:(SessionState*)sessionState withViewController:(UIViewController*)viewController;

@end
