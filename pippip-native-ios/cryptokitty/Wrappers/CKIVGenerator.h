//
//  CKIVGenerator.h
//  pippip-native-ios
//
//  Created by Steve Brenneis on 2/6/18.
//  Copyright © 2018 seComm. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CKIVGenerator : NSObject

- (NSData*_Nonnull)generate:(NSInteger)counter withNonce:(NSData*_Nonnull)nonce;

@end

