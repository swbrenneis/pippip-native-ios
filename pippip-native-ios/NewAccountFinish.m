//
//  NewAccountFinish.m
//  pippip-native-ios
//
//  Created by Steve Brenneis on 10/25/17.
//  Copyright © 2017 seComm. All rights reserved.
//

#import "NewAccountFinish.h"
#import "NSData+HexEncode.h"
#import "CKRSACodec.h"

@interface NewAccountFinish ()
{

}

@property (weak, nonatomic) SessionState *sessionState;

@end

@implementation NewAccountFinish

- (instancetype)initWithState:(SessionState*)state {
    self = [super init];
    
    _sessionState = state;
    return self;
}

- (NSDictionary*)restPacket {

    NSMutableDictionary *packet = [[NSMutableDictionary alloc] init];
    [packet setObject:[NSString stringWithFormat:@"%d", _sessionState.sessionId]
               forKey:@"sessionId"];

    CKRSACodec *codec = [[CKRSACodec alloc] init];
    [codec putBlock:_sessionState.genpass];
    [codec putBlock:_sessionState.enclaveKey];
    [codec putBlock:_sessionState.svpswSalt];
    NSData *data = [codec encrypt:_sessionState.serverPublicKey];
    packet[@"data"] = [data base64EncodedStringWithOptions:0];

    return packet;

}

- (double)restTimeout {
    return 20.0;
}

- (NSString*)restURL {
    return @"https://pippip.secomm.cc/authenticator/new-account-finish";
}

@end
