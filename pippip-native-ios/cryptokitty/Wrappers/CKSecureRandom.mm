//
//  CKSecureRandom.m
//  CryptoKitty_iOS
//
//  Created by Steve Brenneis on 10/4/17.
//  Copyright © 2017 CryptoKitty. All rights reserved.
//

#import "CKSecureRandom.h"
#import "IosSecureRandom.h"
#import "ByteArray.h"
#import "Int32.h"
#import "Int64.h"

@implementation CKSecureRandom

- (NSData*) nextBytes:(int)count {

    IosSecureRandom rnd;
    coder::ByteArray bytes(count);
    rnd.nextBytes(bytes);
    return [[NSMutableData alloc] initWithBytesNoCopy:bytes.asArray()
                                               length:count
                                         freeWhenDone:YES];

}

- (int32_t) nextInt {

    IosSecureRandom rnd;
    coder::ByteArray bytes(4);
    rnd.nextBytes(bytes);
    coder::Int32 i32(bytes);
    return i32.getValue();

}

- (int64_t) nextLong {
    
    IosSecureRandom rnd;
    coder::ByteArray bytes(8);
    rnd.nextBytes(bytes);
    coder::Int64 i64(bytes);
    return i64.getValue();
    
}

@end
