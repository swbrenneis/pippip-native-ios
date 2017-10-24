//
//  RequestProcess.h
//  pippip-native-ios
//
//  Created by Steve Brenneis on 10/20/17.
//  Copyright © 2017 seComm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SessionState.h"

@protocol RequestStep;

@protocol RequestProcess <NSObject>

@required

@property (nonatomic, readonly) id<RequestStep> firstStep;
@property (nonatomic, readonly) id<RequestStep> nextStep;
@property (nonatomic) SessionState *sessionState;

- (void)sessionComplete:(BOOL)success;

- (void)stepComplete:(BOOL)success;

@end
