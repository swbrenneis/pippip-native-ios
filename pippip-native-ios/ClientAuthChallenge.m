//
//  ClientAuthChallenge.m
//  pippip-native-ios
//
//  Created by Steve Brenneis on 12/4/17.
//  Copyright © 2017 seComm. All rights reserved.
//

#import "ClientAuthChallenge.h"
#import "CKSHA256.h"
#import "CKHMAC.h"
#import "CKRSAPrivateKey.h"
#import "CKSignature.h"
#import "NSData+HexEncode.h"

@interface ClientAuthChallenge ()
{

    SessionState *sessionState;
    NSData *hmacKey;

}
@end

@implementation ClientAuthChallenge

- (instancetype)initWithState:(SessionState *)state {
    self = [super init];
    
    sessionState = state;
    return self;
    
}

- (NSDictionary*)restPacket {
    
    NSMutableDictionary *packet = [[NSMutableDictionary alloc] init];
    [packet setObject:[NSString stringWithFormat:@"%d", sessionState.sessionId]
               forKey:@"sessionId"];

    [self s2k];
    CKHMAC *mac = [[CKHMAC alloc] initWithSHA256];
    [mac setKey:hmacKey];
    NSMutableData *message = [NSMutableData data];
    [message appendData:sessionState.clientAuthRandom];
    NSString *tag = @"secomm server";
    [message appendData:[tag dataUsingEncoding:NSUTF8StringEncoding]];
    NSString *msgStr = [message encodeHexString];
    [mac setMessage:message];
    NSData *hmac = [mac getHMAC];
    NSString *hmacStr = [hmac encodeHexString];
    [packet setObject:[hmac encodeHexString] forKey:@"hmac"];

    CKSignature *sig = [[CKSignature alloc] initWithSHA256];
    NSData *signature = [sig sign:sessionState.userPrivateKey withMessage:hmac];
    [packet setObject:[signature encodeHexString] forKey:@"signature"];

    return packet;

}

- (double)restTimeout {
    return 10.0;
}

- (NSString*)restURL {
    return @"https://pippip.secomm.cc/authenticator/authentication-challenge";
}

- (void) s2k {
    
    NSData *genpass = sessionState.genpass;
    unsigned char c;
    [genpass getBytes:&c range:NSMakeRange(genpass.length-1, 1)];
    long count =  c & 0x0f;
    if (count == 0) {
        count = 0x0c;
    }
    count = count << 16;

    NSMutableData *message = [NSMutableData data];
    [message appendData:genpass];
    NSString *secomm = @"@secomm.org";
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
