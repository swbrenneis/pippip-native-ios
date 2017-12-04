//
//  ServerAuthChallenge.m
//  pippip-native-ios
//
//  Created by Steve Brenneis on 12/4/17.
//  Copyright © 2017 seComm. All rights reserved.
//

#import "ServerAuthChallenge.h"

@interface ServerAuthChallenge ()
{

    SessionState *sessionState;

}
@end

@implementation ServerAuthChallenge

- (instancetype)initWithState:(SessionState *)state {
    self = [super init];
    
    sessionState = state;
    return self;
    
}

@end
