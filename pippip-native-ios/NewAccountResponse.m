//
//  NewAccountResponse.m
//  pippip-native-ios
//
//  Created by Steve Brenneis on 10/10/17.
//  Copyright © 2017 seComm. All rights reserved.
//

#import "NewAccountResponse.h"
#import "NSData+HexEncode.h"
#import <CryptoKitty_iOS/CryptoKitty_iOS.h>

@interface NewAccountResponse ()
{
    SessionState *sessionState;
    id<RESTResponseDelegate> responseDelegate;
}
@end

@implementation NewAccountResponse

- (instancetype)initWithState:(SessionState *)state responseDelegate:(id<RESTResponseDelegate>)delegate {
    self = [super init];

    sessionState = state;
    responseDelegate = delegate;
    return self;

}

- (void)restError:(NSString *)error {
    [responseDelegate responseComplete:error];
}

- (void)restResponse:(NSDictionary *)response {

    NSString *error = [response objectForKey:@"error"];
    if (error != nil) {
        [responseDelegate responseComplete:error];
    }
    else {
        sessionState.serverPublicKeyPEM = [response objectForKey:@"serverPublicKey"];
        NSString *encrypted = [response objectForKey:@"encrypted"];
        if (sessionState.serverPublicKeyPEM == nil || encrypted == nil) {
            [responseDelegate responseComplete:@"Invalid server response"];
        }
        else {
            NSData *data = [[NSData alloc] initWithHexString:encrypted];
            CKRSACodec *codec = [[CKRSACodec alloc] initWithData:data];
            CKPEMCodec *pem = [[CKPEMCodec alloc] init];
            CKRSAPrivateKey *pk = [pem decodePrivateKey:sessionState.userPrivateKeyPEM];
            [codec decrypt:pk];
            sessionState.accountRandom = [codec getBlock];
            [responseDelegate responseComplete:nil];
        }
    }

}

@end
