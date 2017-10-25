//
//  NewAccountFinish.m
//  pippip-native-ios
//
//  Created by Steve Brenneis on 10/25/17.
//  Copyright © 2017 seComm. All rights reserved.
//

#import "NewAccountFinish.h"
#import "NSData+HexEncode.h"
#import <cryptokitty_native_ios/cryptokitty_native_ios.h>

@interface NewAccountFinish ()
{
    SessionState *sessionState;
}
@end

@implementation NewAccountFinish

- (instancetype)initWithState:(SessionState*)state {
    self = [super init];
    
    sessionState = state;
    return self;
}

- (NSDictionary*)restPacket {

    NSMutableDictionary *packet = [[NSMutableDictionary alloc] init];
    [packet setObject:@"Authenticator" forKey:@"applicationName"];
    [packet setObject:@"NewAccountRequest" forKey:@"messageType"];
    [packet setObject:[NSString stringWithFormat:@"%d", sessionState.sessionId]
               forKey:@"sessionId"];
    [packet setObject:[NSString stringWithFormat:@"%d", 0]
               forKey:@"authToken"];

    CKRSACodec *codec = [[CKRSACodec alloc] init];
    [codec putBlock:sessionState.genpass];
    [codec putBlock:sessionState.enclaveKey];
    [codec putBlock:sessionState.svpswSalt];
    NSData *data = [codec encrypt:sessionState.serverPublicKey];
    [packet setObject:[data encodeHexString] forKey:@"data"];

    return packet;

}

- (double)restTimeout {
    return 10.0;
}

- (NSString*)restURL {
    return @"https://pippip.secomm.cc/authenticator/new-account-finish";
}

@end
