//
//  UserVault.m
//  pippip-native-ios
//
//  Created by Steve Brenneis on 11/30/17.
//  Copyright © 2017 seComm. All rights reserved.
//

#import "UserVault.h"
#import "CKSHA256.h"
#import "CKGCMCodec.h"
#import "CKPEMCodec.h"

@interface UserVault ()
{

    SessionState *sessionState;

}
@end

@implementation UserVault

- (instancetype)initWithState:(SessionState*)state {
    self = [super init];
    
    sessionState = state;
    return self;
}

- (void) decode:(NSData*)data withPassword:(NSString *)password withError:(NSError**)error {

    CKSHA256 *digest = [[CKSHA256 alloc] init];
    NSData *authData = [password dataUsingEncoding:NSUTF8StringEncoding];
    NSData *vaultKey = [digest digest:authData];
    
    CKGCMCodec *codec = [[CKGCMCodec alloc] initWithData:data];
    [codec decrypt:vaultKey withAuthData:authData withError:error];
    
    if (*error == nil) {
        sessionState.publicId = [codec getString];
        sessionState.accountRandom = [codec getBlock];
        sessionState.genpass = [codec getBlock];
        sessionState.svpswSalt = [codec getBlock];
        sessionState.authData = [codec getBlock];
        sessionState.enclaveKey = [codec getBlock];
        sessionState.contactsKey = [codec getBlock];
        sessionState.userPrivateKeyPEM = [codec getString];
        sessionState.userPublicKeyPEM = [codec getString];
        
        CKPEMCodec *pem = [[CKPEMCodec alloc] init];
        sessionState.userPrivateKey = [pem decodePrivateKey:sessionState.userPrivateKeyPEM];
        sessionState.userPublicKey = [pem decodePublicKey:sessionState.userPublicKeyPEM];
    }

}

- (NSData*) encode:(NSString*)password {

    CKSHA256 *digest = [[CKSHA256 alloc] init];
    NSData *authData = [password dataUsingEncoding:NSUTF8StringEncoding];
    NSData *vaultKey = [digest digest:authData];
    
    CKGCMCodec *codec = [[CKGCMCodec alloc] init];
    [codec putString:sessionState.publicId];
    [codec putBlock:sessionState.accountRandom];
    [codec putBlock:sessionState.genpass];
    [codec putBlock:sessionState.svpswSalt];
    [codec putBlock:sessionState.authData];
    [codec putBlock:sessionState.enclaveKey];
    [codec putBlock:sessionState.contactsKey];
    [codec putString:sessionState.userPrivateKeyPEM];
    [codec putString:sessionState.userPublicKeyPEM];
    NSError *error = nil;
    NSData *encoded = [codec encrypt:vaultKey withAuthData:authData withError:&error];
    if (error != nil) {
        NSLog(@"Error while encrypting vault: %@", error.localizedDescription);
    }
    return encoded;

}

@end
