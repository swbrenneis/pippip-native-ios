//
//  CKIVGenerator.h
//  pippip-native-ios
//
//  Created by Steve Brenneis on 2/6/18.
//  Copyright © 2018 seComm. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CKIVGenerator : NSObject

- (NSData*)generate:(NSInteger)counter withNonce:(NSData*)nonce;

@end

