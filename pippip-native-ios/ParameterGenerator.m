//
//  ParameterGenerator.m
//  pippip-native-ios
//
//  Created by Steve Brenneis on 10/10/17.
//  Copyright © 2017 seComm. All rights reserved.
//

#import "ParameterGenerator.h"
#import "NSData+HexEncode.h"
#import <cryptokitty_native_ios/cryptokitty_native_ios.h>

@implementation ParameterGenerator

- (void)generateParameters:(NSString *)accountName {

    CKSecureRandom *rnd = [[CKSecureRandom alloc] init];

    // Create generated password.
    self.genpass = [rnd nextBytes:20];

    // Create the server vault passphrase salt.
    self.svpswSalt = [rnd nextBytes:8];

    // Create GCM authentication data.
    CKSHA256 *digest = [[CKSHA256 alloc] init];
    self.authData = [digest digest:self.genpass];

    // Create the message AES block cipher key.
    NSData *keyRandom = [rnd nextBytes:32];
    self.enclaveKey = [digest digest:keyRandom];

    // Create the contact database AES block cipher key.
    keyRandom = [rnd nextBytes:32];
    self.contactsKey = [digest digest:keyRandom];

    // Create the user RSA keys.
    CKRSAKeyPairGenerator *gen = [[CKRSAKeyPairGenerator alloc] init];
    CKRSAKeyPair *pair = [gen generateKeyPair:2048];
    CKPEMCodec *pem = [[CKPEMCodec alloc] init];
    self.userPrivateKey = pair.privateKey;
    self.userPublicKey = pair.publicKey;
    self.userPrivateKeyPEM = [pem encodePrivateKey:pair.privateKey withPublicKey:pair.publicKey];
    self.userPublicKeyPEM = [pem encodePublicKey:pair.publicKey];

    // Create the public ID.
    CKSHA1 *sha1 = [[CKSHA1 alloc] init];
    NSData* data = [accountName dataUsingEncoding:NSUTF8StringEncoding];
    [sha1 update:data];
    long long now = NSDate.timeIntervalSinceReferenceDate * 1000;
    NSData *timebytes = [NSData dataWithBytes:&now length:sizeof(long long)];
    [sha1 update:timebytes];
    NSString *seStr = [[NSString alloc] initWithUTF8String:"@secomm.org"];
    NSData* seData = [seStr dataUsingEncoding:NSUTF8StringEncoding];
    [sha1 update:seData];
    self.publicId = [[sha1 digest] encodeHexString];

}

@end
