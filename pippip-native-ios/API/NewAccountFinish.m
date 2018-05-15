//
//  NewAccountFinish.m
//  pippip-native-ios
//
//  Created by Steve Brenneis on 10/25/17.
//  Copyright © 2017 seComm. All rights reserved.
//

#import "pippip_native_ios-Swift.h"
#import "NewAccountFinish.h"
#import "ApplicationSingleton.h"
#import "AccountManager.h"
#import "CKRSACodec.h"

@interface NewAccountFinish ()
{
    SessionState *sessionState;
}

@end

@implementation NewAccountFinish

- (instancetype)init {
    self = [super init];
    
    sessionState = [[SessionState alloc] init];
    return self;
}

- (NSDictionary*)restPacket {

    NSMutableDictionary *packet = [[NSMutableDictionary alloc] init];
    [packet setObject:[NSString stringWithFormat:@"%d", sessionState.sessionId]
               forKey:@"sessionId"];

    CKRSACodec *codec = [[CKRSACodec alloc] init];
    [codec putBlock:sessionState.genpass];
    [codec putBlock:sessionState.enclaveKey];
    [codec putBlock:sessionState.svpswSalt];
    NSData *data = [codec encrypt:sessionState.serverPublicKey];
    packet[@"data"] = [data base64EncodedStringWithOptions:0];
#if TARGET_OS_SIMULATOR
    packet[@"deviceToken"] = @"c2ltdWxhdG9y";      // "simulator"
#else
    AccountSession *accountSession = [ApplicationSingleton instance].accountSession;
    packet[@"deviceToken"] = [accountSession.deviceToken base64EncodedStringWithOptions:0];
#endif

    return packet;

}

- (double)restTimeout {
    return 20.0;
}

- (NSString*)restPath {

    if (AccountManager.production) {
        return @"/authenticator/new-account-finish";
    }
    else {
        return @"/new-account-finish";
    }

}

@end
