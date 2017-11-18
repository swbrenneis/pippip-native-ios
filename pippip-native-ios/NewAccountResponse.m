//
//  NewAccountResponse.m
//  pippip-native-ios
//
//  Created by Steve Brenneis on 10/10/17.
//  Copyright © 2017 seComm. All rights reserved.
//

#import "NewAccountResponse.h"
#import "NSData+HexEncode.h"
#import "CKRSACodec.h"

@interface NewAccountResponse ()
{
    SessionState *sessionState;
}
@end

@implementation NewAccountResponse

- (instancetype)initWithState:(SessionState *)state {
    self = [super init];

    sessionState = state;
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
        NSError *error = nil;
        NSData *data = [NSData dataWithHexString:dataStr withError:&error];
        if (error != nil) {
            [errorDelegate responseError:[error localizedDescription]];
            return NO;
        }
        else {
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
