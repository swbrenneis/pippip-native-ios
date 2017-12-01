//
//  NewAccountRequest.m
//  pippip-native-ios
//
//  Created by Steve Brenneis on 10/10/17.
//  Copyright © 2017 seComm. All rights reserved.
//

#import "NewAccountRequest.h"
#import "NSData+HexEncode.h"


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
    [packet setObject:[NSString stringWithFormat:@"%d", 0]
               forKey:@"authToken"];
    [packet setObject:sessionState.userPublicKeyPEM
               forKey:@"userPublicKey"];
    [packet setObject:sessionState.publicId
               forKey:@"publicId"];
    return packet;

}

- (double)restTimeout {
    return 10.0;
}

- (NSString*)restURL {
    return @"https://pippip.secomm.cc/authenticator/new-account-request";
}

@end
