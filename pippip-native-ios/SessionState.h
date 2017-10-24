//
//  SessionState.h
//  pippip-native-ios
//
//  Created by Steve Brenneis on 10/10/17.
//  Copyright © 2017 seComm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <cryptokitty_native_ios/cryptokitty_native_ios.h>

@interface SessionState : NSObject

// Server parameters
@property (nonatomic) uint32_t sessionId;
@property (nonatomic) uint64_t authToken;
@property (nonatomic) NSData *accountRandom;
@property (nonatomic) CKRSAPublicKey *serverPublicKey;

// Generated parameters
@property (nonatomic) NSString *publicId;
@property (nonatomic) NSData *genpass;
@property (nonatomic) NSData *authData;
@property (nonatomic) NSData *enclaveKey;
@property (nonatomic) NSData *contactsKey;
@property (nonatomic) CKRSAPrivateKey *userPrivateKey;
@property (nonatomic) NSString *userPrivateKeyPEM;
@property (nonatomic) CKRSAPublicKey *userPublicKey;
@property (nonatomic) NSString *userPublicKeyPEM;

- (instancetype)init;

@end
