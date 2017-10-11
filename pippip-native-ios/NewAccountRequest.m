//
//  NewAccountRequest.m
//  pippip-native-ios
//
//  Created by Steve Brenneis on 10/10/17.
//  Copyright © 2017 seComm. All rights reserved.
//

#import "NewAccountRequest.h"

@interface NewAccountRequest ()
{
    SessionState *sessionState;
}
@end

@implementation NewAccountRequest

- (instancetype)initWithState:(SessionState*)state {
    self = [super init];

    sessionState = state;
    return self;
}

- (NSDictionary*)restPacket {

    NSMutableDictionary *packet = [[NSMutableDictionary alloc] init];
    [packet setObject:[NSString stringWithFormat:@"%d", sessionState.sessionId]
               forKey:@"sessionId"];
    [packet setObject:sessionState.publicId
               forKey:@"publicId"];
    [packet setObject:sessionState.userPublicKeyPEM
               forKey:@"userPublicKey"];
    return packet;

}

- (double)restTimeout {
    return 10.0;
}

- (NSString*)restURL {
    return @"https://pippip.io:2880/io.pippip.rest/NewAccountRequest";
}

@end
