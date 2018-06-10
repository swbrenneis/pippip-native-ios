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
#import <iostream>

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

- (BOOL) decrypt:(NSData *)key withAuthData:(NSData *)authData error:(NSError **)error {

    try {
        coder::ByteArray ckKey(reinterpret_cast<const uint8_t*>(key.bytes), key.length);
        coder::ByteArray ckAd(reinterpret_cast<const uint8_t*>(authData.bytes), authData.length);
        gcmCodec->decrypt(ckKey, ckAd);
        return YES;
    }
    catch (EncodingException& e) {
        NSDictionary *errorDictionary = @{ NSLocalizedDescriptionKey : [NSString stringWithUTF8String:e.what()] };
        *error = [NSError errorWithDomain:[[NSBundle mainBundle] bundleIdentifier]
                                     code:GCM_DECRYPTION_ERROR
                                 userInfo:errorDictionary];
        return NO;
    }
    
}

- (NSData*) encrypt:(NSData *)key withAuthData:(NSData *)authData {

    try {
        coder::ByteArray ckKey(reinterpret_cast<const uint8_t*>(key.bytes), key.length);
        coder::ByteArray ckAd(reinterpret_cast<const uint8_t*>(authData.bytes), authData.length);
        gcmCodec->encrypt(ckKey, ckAd);
        coder::ByteArray encrypted(gcmCodec->toArray());
        return [[NSMutableData alloc] initWithBytesNoCopy:encrypted.asArray()
                                                   length:encrypted.length()
                                             freeWhenDone:YES];
    }
    catch (EncodingException& e) {
        _lastError = [NSString stringWithUTF8String:e.what()];
        return nil;
    }

}

- (NSData*)getBlock {
    
    coder::ByteArray block;
    *gcmCodec >> block;
    return [[NSMutableData alloc] initWithBytesNoCopy:block.asArray()
                                               length:block.length()
                                         freeWhenDone:YES];
    
}

- (int32_t)getInt {
    
    int32_t number;
    *gcmCodec >> number;
    return number;
    
}

- (int64_t)getLong {
    
    int64_t number;
    *gcmCodec >> number;
    return number;
    
}

- (NSString*)getString {
    
    std::string str;
    *gcmCodec >> str;
    //std::cout << "CKGCMCodec::getString - " << str << std::endl;
    NSString *result = [[NSString alloc] initWithBytes:str.c_str()
                                                length:str.length()
                                              encoding:NSUTF8StringEncoding];
    return result;
    
}

- (void)putBlock:(NSData *)block {
    
    coder::ByteArray bytes(reinterpret_cast<const uint8_t*>(block.bytes), block.length);
    *gcmCodec << bytes;
    
}

- (void)putInt:(int32_t)number {
    
    *gcmCodec << number;
    
}

- (void)putLong:(int64_t)number {
    
    *gcmCodec << number;
    
}

- (void)putString:(NSString *)str {
    
    const char *cstr = [str cStringUsingEncoding:NSUTF8StringEncoding];
    std::string instr(cstr);
    *gcmCodec << instr;
    
}

- (void)setIV:(NSData *)iv {

    coder::ByteArray bytes(reinterpret_cast<const uint8_t*>(iv.bytes), iv.length);
    gcmCodec->setIV(bytes);

}

@end
