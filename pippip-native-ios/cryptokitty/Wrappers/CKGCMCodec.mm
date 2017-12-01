//
//  CKGCMCodec.m
//  pippip-native-ios
//
//  Created by Steve Brenneis on 11/30/17.
//  Copyright © 2017 seComm. All rights reserved.
//

#import "CKGCMCodec.h"
#import "GCMCodec.h"
#import "EncodingException.h"
#import "ErrorCodes.h"

@interface CKGCMCodec ()
{
    GCMCodec *gcmCodec;
}
@end

@implementation CKGCMCodec

- (instancetype)init {
    self = [super init];
    
    gcmCodec = new GCMCodec;
    return self;
    
}

-(instancetype)initWithData:(NSData *)data {
    self = [super init];
    
    coder::ByteArray bytes(reinterpret_cast<const uint8_t*>(data.bytes), data.length);
    gcmCodec = new GCMCodec(bytes);
    return self;
    
}

- (void)dealloc {
    delete gcmCodec;
}

- (void) decrypt:(NSData *)key withAuthData:(NSData *)authData withError:(NSError *__autoreleasing *)error {

    try {
        coder::ByteArray ckKey(reinterpret_cast<const uint8_t*>(key.bytes), key.length);
        coder::ByteArray ckAd(reinterpret_cast<const uint8_t*>(authData.bytes), authData.length);
        gcmCodec->decrypt(ckKey, ckAd);
    }
    catch (EncodingException& e) {
        NSDictionary *errorDictionary = @{ NSLocalizedDescriptionKey : [NSString stringWithUTF8String:e.what()] };
        *error = [NSError errorWithDomain:[[NSBundle mainBundle] bundleIdentifier]
                                     code:GCM_DECRYPTION_ERROR
                                 userInfo:errorDictionary];
    }
    
}

- (NSData*) encrypt:(NSData *)key withAuthData:(NSData *)authData {
    
    coder::ByteArray ckKey(reinterpret_cast<const uint8_t*>(key.bytes), key.length);
    coder::ByteArray ckAd(reinterpret_cast<const uint8_t*>(authData.bytes), authData.length);
    gcmCodec->encrypt(ckKey, ckAd);
    coder::ByteArray encrypted(gcmCodec->toArray());
    return [[NSMutableData alloc] initWithBytesNoCopy:encrypted.asArray()
                                               length:encrypted.length()
                                         freeWhenDone:YES];

}

- (NSData*)getBlock {
    
    coder::ByteArray block;
    *gcmCodec >> block;
    return [[NSMutableData alloc] initWithBytesNoCopy:block.asArray()
                                               length:block.length()
                                         freeWhenDone:YES];
    
}

-(NSString*)getString {
    
    std::string str;
    *gcmCodec >> str;
    return [NSString stringWithUTF8String:str.c_str()];
    
}

- (void)putBlock:(NSData *)block {
    
    coder::ByteArray bytes(reinterpret_cast<const uint8_t*>(block.bytes), block.length);
    *gcmCodec << bytes;
    
}

- (void)putString:(NSString *)str {
    
    const char *cstr = [str cStringUsingEncoding:NSUTF8StringEncoding];
    std::string instr(cstr);
    *gcmCodec << instr;
    
}

@end
