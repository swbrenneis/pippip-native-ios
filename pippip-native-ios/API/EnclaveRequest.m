//
//  EnclaveRequest.m
//  pippip-native-ios
//
//  Created by Steve Brenneis on 12/13/17.
//  Copyright © 2017 seComm. All rights reserved.
//

#import "EnclaveRequest.h"
#import "pippip_native_ios-Swift.h"
#import "ApplicationSingleton.h"
#import "CKGCMCodec.h"

@interface EnclaveRequest ()
{
    NSMutableDictionary *packet;
}

@property (weak, nonatomic) SessionState *sessionState;

@end

@implementation EnclaveRequest

- (instancetype)init {
    self = [super init];
    
    _sessionState = [ApplicationSingleton instance].accountSession.sessionState;
    packet = [[NSMutableDictionary alloc] init];
    return self;

}

- (NSDictionary*)restPacket {
    
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
    NSError *error = nil;
    NSData *encoded = [codec encrypt:_sessionState.enclaveKey withAuthData:_sessionState.authData withError:&error];
    if (error != nil) {
        NSLog(@"Error while encrypting enclave request: %@", error.localizedDescription);
    }
    else {
        packet[@"request"] = [encoded base64EncodedStringWithOptions:0];
    }

}

@end
