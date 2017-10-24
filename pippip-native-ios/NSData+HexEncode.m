//
//  NSData+HexEncode.m
//  SeAccountPlugin
//
//  Created by Steve Brenneis on 10/4/17.
//  Copyright © 2017 seComm. All rights reserved.
//

#import "NSData+HexEncode.h"
#import "ErrorCodes.h"

@implementation NSData (HexEncode)

+ (instancetype)dataWithHexString:(NSString*)hex withError:(NSError**)error {

    // Set up a working C string.
    size_t workingLength = hex.length;
    if (hex.length % 2 != 0) {    // Odd number of characters, prefix a '0'.
        workingLength++;
    }
    char work[workingLength];
    work[0] = 0;
    if (workingLength == hex.length) {
        strncpy(work, [hex cStringUsingEncoding:NSUTF8StringEncoding], hex.length);
    }
    else {
        strncpy(work + 1, [hex cStringUsingEncoding:NSUTF8StringEncoding], hex.length);
    }

    bool hi = true;
    bool stop = false;
    uint8_t byte = 0;
    uint8_t *wbytes = malloc(workingLength / 2);
    for (unsigned i = 0; i < workingLength && !stop; ++i) {
        char c = work[i];
        uint8_t nib = 0;
        if (c >= 'a' && c <= 'f') {
            nib = (c - 'a') + 10;
        }
        if (c >= 'A' && c <= 'F') {
            nib = (c - 'A') + 10;
        }
        else if (c >= '0' && c <= '9') {
            nib = c - '0';
        }
        else {
            stop = true;
            free(wbytes);
            if (error != nil) {
                NSDictionary *errorDictionary = @{ NSLocalizedDescriptionKey : @"Invalid hex string" };
                *error = [NSError errorWithDomain:[[NSBundle mainBundle] bundleIdentifier]
                                             code:INVALID_HEX_STRING
                                         userInfo:errorDictionary];
            }
        }
        if (!stop) {
            if (hi) {
                hi = false;
                byte = nib << 4;
            }
            else {
                byte |= nib;
                wbytes[i / 2] = byte;
                hi = true;
            }
        }
    }
    return [NSData dataWithBytes:wbytes length:workingLength];

}

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
