//
//  AuthenticationResponse.m
//  pippip-native-ios
//
//  Created by Steve Brenneis on 12/4/17.
//  Copyright © 2017 seComm. All rights reserved.
//

#import "AuthenticationResponse.h"
#import "pippip_native_ios-Swift.h"
#import "CKRSACodec.h"

@interface AuthenticationResponse () {

    SessionState *sessionState;

}
@end

@implementation AuthenticationResponse

- (instancetype)init {
    self = [super init];
    
    sessionState = [[SessionState alloc] init];
    return self;
    
}

- (BOOL)processResponse:(NSDictionary *)response errorDelegate:(id<ErrorDelegate>)errorDelegate {
    
    NSString *dataStr = [response objectForKey:@"data"];
    NSString *errorStr = [response objectForKey:@"error"];
    if (errorStr != nil) {
        [errorDelegate responseError:errorStr];
        return NO;
    }
    if (dataStr == nil) {
        [errorDelegate responseError:@"Invalid server response"];
        return NO;
    }
    else {
        NSData *data = [[NSData alloc] initWithBase64EncodedString:dataStr options:0];
        if (data == nil) {
            [errorDelegate responseError:@"Server encoding error"];
            return NO;
        }
        else {
            NSError *error;
            CKRSACodec *codec = [[CKRSACodec alloc] initWithData:data];
            [codec decrypt:sessionState.userPrivateKey withError:&error];
            if (error != nil) {
                [errorDelegate responseError:[error localizedDescription]];
                return NO;
            }
            sessionState.serverAuthRandom = [codec getBlock];
            return YES;
        }
    }
    
}

@end
