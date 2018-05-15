//
//  ServerAuthorized.m
//  pippip-native-ios
//
//  Created by Steve Brenneis on 12/6/17.
//  Copyright © 2017 seComm. All rights reserved.
//

#import "pippip_native_ios-Swift.h"
#import "ServerAuthorized.h"
#import "ApplicationSingleton.h"
#import "AccountManager.h"
#import "CKRSACodec.h"

@interface ServerAuthorized ()
{
    
    SessionState *sessionState;
    
}

@end

@implementation ServerAuthorized

- (instancetype)init {
    self = [super init];
    
    sessionState = [[SessionState alloc] init];
    return self;
    
}

- (NSDictionary*)restPacket {
    
    NSMutableDictionary *packet = [[NSMutableDictionary alloc] init];

    packet[@"sessionId"] = [NSNumber numberWithInt:sessionState.sessionId];
    CKRSACodec *codec = [[CKRSACodec alloc] init];
    [codec putBlock:sessionState.enclaveKey];
    NSData *data = [codec encrypt:sessionState.serverPublicKey];
    packet[@"data"] = [data base64EncodedStringWithOptions:0];
#if !TARGET_OS_SIMULATOR
    AccountSession *accountSession = [ApplicationSingleton instance].accountSession;
    packet[@"deviceToken"] = [accountSession.deviceToken base64EncodedStringWithOptions:0];
#endif
#ifdef DEBUG
    packet[@"developer"] = [NSNumber numberWithBool:YES];
#else
    packet[@"developer"] = [NSNumber numberWithBool:NO];
#endif

    return packet;
    
}

- (double)restTimeout {
    return 15.0;
}

- (NSString*)restPath {
    
    if (AccountManager.production) {
        return @"/authenticator/authorized";
    }
    else {
        return @"/authorized";
    }

}

@end
