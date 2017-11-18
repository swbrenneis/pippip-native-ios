//
//  CKSecureRandom.h
//  CryptoKitty_iOS
//
//  Created by Steve Brenneis on 10/4/17.
//  Copyright © 2017 CryptoKitty. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CKSecureRandom : NSObject

- (NSData*) nextBytes:(int)count;

- (int32_t) nextInt;

- (int64_t) nextLong;

@end
