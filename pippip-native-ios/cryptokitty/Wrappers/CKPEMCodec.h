//
//  CKPEMCodec.h
//  CryptoKitty_iOS
//
//  Created by Steve Brenneis on 10/4/17.
//  Copyright © 2017 CryptoKitty. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CKRSAPrivateKey.h"
#import "CKRSAPublicKey.h"

@interface CKPEMCodec : NSObject

- (NSString*) encodePublicKey:(CKRSAPublicKey*)publicKey;

- (NSString*) encodePrivateKey:(CKRSAPrivateKey*)privateKey withPublicKey:(CKRSAPublicKey*)publicKey;

- (CKRSAPrivateKey*)decodePrivateKey:(NSString*)pem;

- (CKRSAPublicKey*)decodePublicKey:(NSString*)pem;

@end
