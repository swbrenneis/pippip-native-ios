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
    SessionState *sessionState;
}

@end

@implementation Logout

- (instancetype)init {
    self = [super init];
    
    sessionState = [[SessionState alloc] init];
    return self;
}

- (NSDictionary*)restPacket {
    
    NSMutableDictionary *packet = [[NSMutableDictionary alloc] init];
    [packet setObject:[NSString stringWithFormat:@"%d", sessionState.sessionId]
               forKey:@"sessionId"];
    [packet setObject:[NSString stringWithFormat:@"%lld", sessionState.authToken]
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
