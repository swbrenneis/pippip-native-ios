//
//  CKSHA1.m
//  CryptoKitty_iOS
//
//  Created by Steve Brenneis on 10/4/17.
//  Copyright © 2017 CryptoKitty. All rights reserved.
//

#import "CKSHA1.h"
#import "SHA1.h"

@interface CKSHA1 ()
{
    SHA1 *sha1;
    NSMutableData *accumulator;
}
@end

@implementation CKSHA1

- (instancetype) init {
    
    self = [super init];
    
    sha1 = new SHA1;
    accumulator = nil;
    return self;
    
}

- (void) dealloc {

    delete sha1;

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
    coder::ByteArray result(sha1->digest(bytes));
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
