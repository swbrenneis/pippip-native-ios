//
//  RequestProcess.h
//  pippip-native-ios
//
//  Created by Steve Brenneis on 10/20/17.
//  Copyright © 2017 seComm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SessionState.h"

@protocol ErrorDelegate;
@protocol PostPacket;
@protocol RESTResponse;

@protocol RequestProcess <NSObject>

@required

@property (nonatomic, readonly) id<ErrorDelegate> errorDelegate;
@property (nonatomic, readonly) id<PostPacket> postPacket;
@property (nonatomic) SessionState *sessionState;

- (void)sessionComplete:(NSDictionary*)response;

- (void)postComplete:(NSDictionary*)response;

@end
