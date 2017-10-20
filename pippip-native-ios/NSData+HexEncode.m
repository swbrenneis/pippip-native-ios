//
//  NSData+HexEncode.m
//  SeAccountPlugin
//
//  Created by Steve Brenneis on 10/4/17.
//  Copyright © 2017 seComm. All rights reserved.
//

#import "NSData+HexEncode.h"

@implementation NSData (HexEncode)

- (NSString*) encodeHexString {

    const char *toHex = self.bytes;
    char hexStr[(self.length * 2) + 1];
    hexStr[self.length * 2] = 0;
    for (int i = 0; i < self.length; ++i) {
        char upper = (toHex[i] >> 4) & 0x0f;
        if (upper < 0x0a) {
            hexStr[i*2] = upper + '0';
        }
        else {
            hexStr[i*2] = (upper - 0x0a) + 'a';
        }
        char lower = toHex[i] & 0x0f;
        if (lower < 0x0a) {
            hexStr[(i*2)+1] = lower + '0';
        }
        else {
            hexStr[(i*2)+1] = (lower - 0x0a) + 'a';
        }
    }
    return [[NSString alloc] initWithUTF8String:hexStr];

}

@end
