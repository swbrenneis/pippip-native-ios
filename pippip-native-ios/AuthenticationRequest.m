//
//  AuthenticationRequest.m
//  pippip-native-ios
//
//  Created by Steve Brenneis on 12/1/17.
//  Copyright © 2017 seComm. All rights reserved.
//

#import "AuthenticationRequest.h"
#import "CKRSACodec.h"
#import "CKSecureRandom.h"

@interface AuthenticationRequest ()
{
    SessionState *sessionState;
}
@end

@implementation AuthenticationRequest

- (instancetype)initWithState:(SessionState*)state {
    self = [super init];
    
    sessionState = state;
    return self;
}

- (NSDictionary*)restPacket {
    
    NSMutableDictionary *packet = [[NSMutableDictionary alloc] init];
    [packet setObject:[NSString stringWithFormat:@"%d", sessionState.sessionId]
               forKey:@"sessionId"];

    CKSecureRandom *rnd = [[CKSecureRandom alloc] init];
    sessionState.clientAuthRandom = [rnd nextBytes:32];
    CKRSACodec *codec = [[CKRSACodec alloc] init];
    [codec putString:sessionState.publicId];
    [codec putBlock:sessionState.accountRandom];
    [codec putBlock:sessionState.svpswSalt];
    [codec putBlock:sessionState.clientAuthRandom];
    NSData *data = [codec encrypt:sessionState.serverPublicKey];
    packet[@"data"] = [data base64EncodedStringWithOptions:0];

    return packet;
    
}

- (double)restTimeout {
    return 20.0;
}

- (NSString*)restURL {
    return @"https://pippip.secomm.cc/authenticator/authentication-request";
}

@end
