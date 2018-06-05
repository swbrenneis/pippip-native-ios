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

- (instancetype _Nonnull) initWithSHA256;

- (NSData*_Nonnull) sign:(CKRSAPrivateKey*_Nonnull)key withMessage:(NSData*)message;

- (BOOL) verify:(CKRSAPublicKey*_Nonnull)key withMessage:(NSData*_Nonnull)message withSignature:(NSData*_Nonnull)signature;

@end
