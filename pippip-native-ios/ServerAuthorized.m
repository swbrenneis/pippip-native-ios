//
//  ServerAuthorized.m
//  pippip-native-ios
//
//  Created by Steve Brenneis on 12/6/17.
//  Copyright © 2017 seComm. All rights reserved.
//

#import "ServerAuthorized.h"
#import "CKRSACodec.h"
#import "NSData+HexEncode.h"

@interface ServerAuthorized ()
{
    
    SessionState *sessionState;
    
}

@end

@implementation ServerAuthorized

- (instancetype)initWithState:(SessionState *)state {
    self = [super init];
    
    sessionState = state;
    return self;
    
}

- (NSDictionary*)restPacket {
    
    NSMutableDictionary *packet = [[NSMutableDictionary alloc] init];
    [packet setObject:[NSString stringWithFormat:@"%d", sessionState.sessionId]
               forKey:@"sessionId"];
    
    CKRSACodec *codec = [[CKRSACodec alloc] init];
    [codec putBlock:sessionState.enclaveKey];
    NSData *data = [codec encrypt:sessionState.serverPublicKey];
    [packet setObject:[data encodeHexString] forKey:@"data"];

    return packet;
    
}

- (double)restTimeout {
    return 10.0;
}

- (NSString*)restURL {
    return @"https://pippip.secomm.cc/authenticator/authorized";
}

@end
