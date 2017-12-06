//
//  ServerAuthChallenge.m
//  pippip-native-ios
//
//  Created by Steve Brenneis on 12/4/17.
//  Copyright © 2017 seComm. All rights reserved.
//

#import "ServerAuthChallenge.h"
#import "CKHMAC.h"
#import "CKSignature.h"
#import "CKSHA256.h"
#import "NSData+HexEncode.h"

@interface ServerAuthChallenge ()
{

    SessionState *sessionState;
    NSData *hmacKey;

}
@end

@implementation ServerAuthChallenge

- (instancetype)initWithState:(SessionState *)state {
    self = [super init];
    
    sessionState = state;
    return self;
    
}

- (BOOL)processResponse:(NSDictionary *)response errorDelegate:(id<ErrorDelegate>)errorDelegate {

    NSString *hmacStr = [response objectForKey:@"hmac"];
    NSString *sigStr = [response objectForKey:@"signature"];
    NSString *errorStr = [response objectForKey:@"error"];
    if (errorStr != nil) {
        [errorDelegate responseError:errorStr];
        return NO;
    }

    if (hmacStr == nil || sigStr == nil) {
        [errorDelegate responseError:@"Invalid server response"];
        return NO;
    }
    else {
        NSError *error = nil;
        NSData *hmac = [NSData dataWithHexString:hmacStr withError:&error];
        if (error != nil) {
            [errorDelegate responseError:@"Invalid HMAC hex encoding"];
            return NO;
        }
        NSData *signature = [NSData dataWithHexString:sigStr withError:&error];
        if (error != nil) {
            [errorDelegate responseError:@"Invalid signature hex encoding"];
            return NO;
        }

        CKSignature *sig = [[CKSignature alloc] init];
        if (![sig verify:sessionState.serverPublicKey withMessage:hmac withSignature:signature]) {
            [errorDelegate responseError:@"Signature not verified"];
            return NO;
        }

        CKHMAC *mac = [[CKHMAC alloc] init];
        [mac setKey:hmacKey];
        NSMutableData *message = [NSMutableData data];
        [message appendData:sessionState.serverAuthRandom];
        NSString *tag = @"secomm client";
        [message appendData:[tag dataUsingEncoding:NSUTF8StringEncoding]];
        if (![mac authenticate:hmac]) {
            [errorDelegate responseError:@"Authentication failed"];
            return NO;
        }
        else {
            return YES;
        }

    }

}

- (void) s2k {
    
    NSData *genpass = sessionState.genpass;
    unsigned char c;
    [genpass getBytes:&c range:NSMakeRange(genpass.length-1, 1)];
    unsigned long count =  c & 0x0f;
    if (count == 0) {
        count = 0x0c;
    }
    count = count << 16;
    
    NSMutableData *message = [NSMutableData data];
    [message appendData:genpass];
    NSString *secomm = @"secomm.org";
    [message appendData:[secomm dataUsingEncoding:NSUTF8StringEncoding]];
    [message appendData:sessionState.accountRandom];
    
    CKSHA256 *digest = [[CKSHA256 alloc] init];
    NSData *hash = [digest digest:message];
    count -= 32;
    while (count > 0) {
        NSMutableData *ctx = message.mutableCopy;
        [ctx appendData:hash];
        hash = [digest digest:ctx];
        count = count - 32 - message.length;
    }
    hmacKey = hash;
    
}

@end
