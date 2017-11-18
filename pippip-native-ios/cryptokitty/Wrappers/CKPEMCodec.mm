//
//  CKPEMCodec.m
//  CryptoKitty_iOS
//
//  Created by Steve Brenneis on 10/4/17.
//  Copyright © 2017 CryptoKitty. All rights reserved.
//

#import "CKPEMCodec.h"
#import "PEMCodec.h"
#include <sstream>

@implementation CKPEMCodec

- (NSString*) encodePublicKey:(CKRSAPublicKey*)publicKey {

    RSAPublicKey *pub = reinterpret_cast<RSAPublicKey*>(publicKey.publicKey);
    std::ostringstream kstr;
    PEMCodec codec(true);   // X.509 keys
    codec.encode(kstr, *pub);
    
    return [[NSString alloc] initWithUTF8String:kstr.str().c_str()];

}

- (NSString*) encodePrivateKey:(CKRSAPrivateKey*)privateKey withPublicKey:(CKRSAPublicKey*)publicKey {

    RSAPublicKey *pub = reinterpret_cast<RSAPublicKey*>(publicKey.publicKey);
    RSAPrivateKey *prv = reinterpret_cast<RSAPrivateKey*>(privateKey.privateKey);
    std::ostringstream kstr;
    PEMCodec codec(true);   // X.509 keys
    codec.encode(kstr, *prv, *pub);

    return [[NSString alloc] initWithUTF8String:kstr.str().c_str()];

}

- (CKRSAPrivateKey*)decodePrivateKey:(NSString*)pem {
    
    PEMCodec codec(true);   // X.509 keys
    std::string pemStr([pem cStringUsingEncoding:NSUTF8StringEncoding]);
    RSAPrivateKey *pk = codec.decodePrivateKey(pemStr);
    return [[CKRSAPrivateKey alloc] initWithKey:pk];
    
}

- (CKRSAPublicKey*)decodePublicKey:(NSString*)pem {
    
    PEMCodec codec(true);   // X.509 keys
    std::string pemStr([pem cStringUsingEncoding:NSUTF8StringEncoding]);
    RSAPublicKey *pk = codec.decodePublicKey(pemStr);
    return [[CKRSAPublicKey alloc] initWithKey:pk];
    
}

@end
