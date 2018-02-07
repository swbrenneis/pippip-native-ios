//
//  CKIVGenerator.mm
//  pippip-native-ios
//
//  Created by Steve Brenneis on 2/6/18.
//  Copyright © 2018 seComm. All rights reserved.
//

#import "CKIVGenerator.h"
#import "Int64.h"

@implementation CKIVGenerator

- (NSData*)generate:(NSInteger)counter withNonce:(NSData*)nonce {

    coder::Int64 i64(counter);
    coder::ByteArray nonceBytes(reinterpret_cast<const uint8_t*>(nonce.bytes), nonce.length);
    nonceBytes.append(i64.getEncoded().range(4));   // Low order bytes

    return [NSData dataWithBytesNoCopy:nonceBytes.asArray() length:nonceBytes.length()];

}

@end
