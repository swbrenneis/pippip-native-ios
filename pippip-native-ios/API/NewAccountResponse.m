//
//  NewAccountResponse.m
//  pippip-native-ios
//
//  Created by Steve Brenneis on 10/10/17.
//  Copyright © 2017 seComm. All rights reserved.
//

#import "NewAccountResponse.h"
#import "pippip_native_ios-Swift.h"
#import "CKRSACodec.h"

@interface NewAccountResponse ()
{
    SessionState *sessionState;
}
@end

@implementation NewAccountResponse

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
            [errorDelegate responseError:@"Response encoding error"];
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
            sessionState.accountRandom = [codec getBlock];
            return YES;
        }
    }

}

@end
