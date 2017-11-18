//
//  CKSHA256.m
//  CryptoKitty_iOS
//
//  Created by Steve Brenneis on 10/4/17.
//  Copyright © 2017 CryptoKitty. All rights reserved.
//

#import "CKSHA256.h"
#import "SHA256.h"

@interface CKSHA256 ()
{
    SHA256 *sha256;
    NSMutableData *accumulator;
}
@end;

@implementation CKSHA256

- (instancetype) init {

    self = [super init];

    sha256 = new SHA256;
    accumulator = nil;
    return self;

}

- (void) dealloc {

    delete sha256;

}

- (NSData*) digest {

    if (accumulator == nil) {
        return [self digest:[NSData data]]; // Empty digest.
    }
    else {
        NSData *result = [self digest:accumulator];
        [self reset];
        return result;
    }

}

- (NSData*) digest:(NSData *)data {

    [self reset];
    coder::ByteArray bytes;
    if (data.length > 0) {
        const uint8_t *dataBytes = reinterpret_cast<const uint8_t*>(data.bytes);
        bytes = coder::ByteArray(dataBytes, data.length);
    }
    coder::ByteArray result(sha256->digest(bytes));
    return [[NSData alloc] initWithBytesNoCopy:result.asArray()
                                        length:result.length()
                                  freeWhenDone:YES];

}

- (void) reset {

    accumulator = nil;

}

- (void) update:(NSData *)data {

    if (accumulator == nil) {
        accumulator = [NSMutableData data];
    }
    [accumulator appendData:data];

}

@end
