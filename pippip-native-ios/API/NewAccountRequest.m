//
//  NewAccountRequest.m
//  pippip-native-ios
//
//  Created by Steve Brenneis on 10/10/17.
//  Copyright © 2017 seComm. All rights reserved.
//

#import "pippip_native_ios-Swift.h"
#import "NewAccountRequest.h"


@interface NewAccountRequest ()
{
    SessionState *sessionState;
}
@end

@implementation NewAccountRequest

- (instancetype)init {
    self = [super init];

    sessionState = [[SessionState alloc] init];
    return self;
}

- (NSDictionary*)restPacket {

    NSMutableDictionary *packet = [[NSMutableDictionary alloc] init];
    [packet setObject:[NSString stringWithFormat:@"%d", sessionState.sessionId]
               forKey:@"sessionId"];
    packet[@"userPublicKey"] = sessionState.userPublicKeyPEM;
    packet[@"publicId"] = sessionState.publicId;

    return packet;

}

- (double)restTimeout {
    return 10.0;
}

- (NSString*)restURL {
    return @"https://pippip.secomm.cc/authenticator/new-account-request";
}

@end
