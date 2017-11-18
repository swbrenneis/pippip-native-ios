//
//  CKRSAKeyPairGenerator.h
//  CryptoKitty_iOS
//
//  Created by Steve Brenneis on 10/3/17.
//  Copyright © 2017 CryptoKitty. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CKRSAKeyPair.h"

@interface CKRSAKeyPairGenerator : NSObject

- (CKRSAKeyPair*) generateKeyPair:(int)bitsize;

@end
