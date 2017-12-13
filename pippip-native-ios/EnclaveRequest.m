//
//  EnclaveRequest.m
//  pippip-native-ios
//
//  Created by Steve Brenneis on 12/13/17.
//  Copyright © 2017 seComm. All rights reserved.
//

#import "EnclaveRequest.h"
#import "CKGCMCodec.h"
#import "NSData+HexEncode.h"

@interface EnclaveRequest ()
{
    SessionState *sessionState;
    NSMutableDictionary *packet;

}

@end

@implementation EnclaveRequest

- (instancetype)initWithState:(SessionState*)state {
    self = [super init];
    
    sessionState = state;
    packet = [[NSMutableDictionary alloc] init];
    return self;

}

- (NSDictionary*)restPacket {
    
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
    return @"https://pippip.secomm.cc/enclave/enclave-request";
}

- (void) setRequest:(NSDictionary *)request {

    NSError *jsonError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:request
                                                   options:0
                                                     error:&jsonError];
    NSString *json = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    CKGCMCodec *codec = [[CKGCMCodec alloc] init];
    [codec putString:json];
    NSData *encoded = [codec encrypt:sessionState.enclaveKey withAuthData:sessionState.authData];
    packet[@"request"] = [encoded encodeHexString];

}

@end
