//
//  CKSignature.h
//  pippip-native-ios
//
//  Created by Steve Brenneis on 12/4/17.
//  Copyright © 2017 seComm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CKRSAPrivateKey.h"
#import "CKRSAPublicKey.h"

@interface CKSignature : NSObject

- (instancetype) initWithSHA256;

- (NSData*) sign:(CKRSAPrivateKey*)key withMessage:(NSData*)message;

- (BOOL) verify:(CKRSAPublicKey*)key withMessage:(NSData*)message withSignature:(NSData*)signature;

@end
