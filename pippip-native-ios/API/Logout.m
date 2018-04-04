//
//  Logout.m
//  pippip-native-ios
//
//  Created by Steve Brenneis on 12/10/17.
//  Copyright © 2017 seComm. All rights reserved.
//

#import "Logout.h"
#import "pippip_native_ios-Swift.h"

@interface Logout ()
{
    
}

@property (weak, nonatomic) SessionState *sessionState;

@end

@implementation Logout

- (instancetype)initWithState:(SessionState*)state {
    self = [super init];
    
    _sessionState = state;
    return self;
}

- (NSDictionary*)restPacket {
    
    NSMutableDictionary *packet = [[NSMutableDictionary alloc] init];
    [packet setObject:[NSString stringWithFormat:@"%d", _sessionState.sessionId]
               forKey:@"sessionId"];
    [packet setObject:[NSString stringWithFormat:@"%lld", _sessionState.authToken]
               forKey:@"authToken"];

    return packet;

}

- (double)restTimeout {
    return 10.0;
}

- (NSString*)restURL {
    return @"https://pippip.secomm.cc/authenticator/logout";
}

@end
