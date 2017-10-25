//
//  SessionState.m
//  pippip-native-ios
//
//  Created by Steve Brenneis on 10/10/17.
//  Copyright © 2017 seComm. All rights reserved.
//

#import "SessionState.h"

@implementation SessionState

- (instancetype)init {
    self = [super init];

    _sessionId = 0;
    _authToken = 0;
    _authenticated = NO;

    return self;
}

@end
