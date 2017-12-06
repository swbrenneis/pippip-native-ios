//
//  CKHMAC.m
//  pippip-native-ios
//
//  Created by Steve Brenneis on 12/4/17.
//  Copyright © 2017 seComm. All rights reserved.
//

#import "CKHMAC.h"
#import "HMAC.h"
#import "SHA256.h"
#import "ByteArray.h"

@interface CKHMAC ()
{

    HMAC *hmac;

}
@end

@implementation CKHMAC

- (instancetype) initWithSHA256 {
    self = [super init];

    hmac = new HMAC(new SHA256);

    return self;

}

- (void) dealloc {
    delete hmac;
}

- (BOOL) authenticate:(NSData *)message {

    coder::ByteArray hmacMessage(reinterpret_cast<const uint8_t*>(message.bytes), message.length);
    return hmac->authenticate(hmacMessage) ? YES : NO;


}

- (NSData*) getHMAC {

    coder::ByteArray hmacBytes(hmac->getHMAC());
    return [NSData dataWithBytesNoCopy:hmacBytes.asArray()
                                length:hmacBytes.length()
                          freeWhenDone:YES];

}

- (void) setKey:(NSData *)key {

    coder::ByteArray hmacKey(reinterpret_cast<const uint8_t*>(key.bytes), key.length);
    hmac->setKey(hmacKey);
    
}

- (void) setMessage:(NSData *)message {

    coder::ByteArray hmacMessage(reinterpret_cast<const uint8_t*>(message.bytes), message.length);
    hmac->setMessage(hmacMessage);
    
}

@end
