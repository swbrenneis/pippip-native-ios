//
//  RequestStep.h
//  pippip-native-ios
//
//  Created by Steve Brenneis on 10/20/17.
//  Copyright © 2017 seComm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PostPacket.h"
#import "ErrorDelegate.h"
#import "RESTSession.h"
#import "RESTResponse.h"

@protocol RequestStep <NSObject>

@property (nonatomic, readonly) id<ErrorDelegate> errorDelegate;
@property (nonatomic, readonly) id<PostPacket> postPacket;
@property (nonatomic, readonly) id<RESTResponse> response;

- (void)step:(RESTSession*)session;

@end
