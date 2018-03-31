//
//  HexCodec.m
//  pippip-native-ios
//
//  Created by Steve Brenneis on 3/22/18.
//  Copyright © 2018 seComm. All rights reserved.
//

#import "HexCodec.h"

@implementation HexCodec

+ (NSString*)hexString:(NSData*)binary {
    
    const char *toHex = binary.bytes;
    char hexStr[(binary.length * 2) + 1];
    hexStr[binary.length * 2] = 0;
    for (int i = 0; i < binary.length; ++i) {
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
