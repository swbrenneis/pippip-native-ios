//
//  CKSignature.m
//  pippip-native-ios
//
//  Created by Steve Brenneis on 12/4/17.
//  Copyright © 2017 seComm. All rights reserved.
//

#import "CKSignature.h"
#import "PKCS1rsassa.h"
#import "SHA256.h"
#import "RSAPrivateKey.h"
#import "RSAPublicKey.h"
#import "ByteArray.h"

@interface CKSignature ()
{
    PKCS1rsassa *sig;
}
@end

@implementation CKSignature

- (instancetype) initWithSHA256 {
    self = [super init];

    sig = new PKCS1rsassa(new SHA256);

    return self;

}

- (void) dealloc {
    delete sig;
}

- (NSData*) sign:(CKRSAPrivateKey *)key withMessage:(NSData *)message {

    RSAPrivateKey *pk = reinterpret_cast<RSAPrivateKey*>(key.privateKey);
    coder::ByteArray msg(reinterpret_cast<const uint8_t*>(message.bytes), message.length);
    coder::ByteArray signature(sig->sign(*pk, msg));
    return [NSData dataWithBytesNoCopy:signature.asArray()
                                length:signature.length()
                          freeWhenDone:YES];

}

- (BOOL) verify:(CKRSAPublicKey *)key withMessage:(NSData *)message withSignature:(NSData *)signature {

    RSAPublicKey *pk = reinterpret_cast<RSAPublicKey*>(key.publicKey);
    coder::ByteArray msg(reinterpret_cast<const uint8_t*>(message.bytes), message.length);
    coder::ByteArray sgn(reinterpret_cast<const uint8_t*>(signature.bytes), signature.length);
    return sig->verify(*pk, msg, sgn) ? YES : NO;

}

@end
