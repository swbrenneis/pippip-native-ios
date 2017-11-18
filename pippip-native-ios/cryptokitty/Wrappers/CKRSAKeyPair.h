//
//  CKRSAKeyPair.h
//  CryptoKitty_iOS
//
//  Created by Steve Brenneis on 10/3/17.
//  Copyright © 2017 CryptoKitty. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CKRSAPrivateKey.h"
#import "CKRSAPublicKey.h"

@interface CKRSAKeyPair : NSObject

@property (nonatomic, readonly) CKRSAPrivateKey *privateKey;
@property (nonatomic, readonly) CKRSAPublicKey *publicKey;

- (instancetype) initWithKeys:(CKRSAPrivateKey*)privateKey withPublicKey:(CKRSAPublicKey*)publicKey;

@end
