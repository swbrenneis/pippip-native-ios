//
//  SessionState.h
//  pippip-native-ios
//
//  Created by Steve Brenneis on 10/10/17.
//  Copyright © 2017 seComm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CKRSAPublicKey.h"
#import "CKRSAPrivateKey.h"

@interface SessionState : NSObject

// Authentication state parameters
@property (nonatomic) NSString *currentAccount;
@property (nonatomic) NSString *passphrase;
@property (nonatomic) BOOL authenticated;

// Server parameters
@property (nonatomic) uint32_t sessionId;
@property (nonatomic) uint64_t authToken;
@property (nonatomic) NSData *accountRandom;
@property (nonatomic) CKRSAPublicKey *serverPublicKey;

// Generated parameters
@property (nonatomic) NSString *publicId;
@property (nonatomic) NSData *genpass;
@property (nonatomic) NSData *svpswSalt;    // Server vault passphrase salt.
@property (nonatomic) NSData *authData;
@property (nonatomic) NSData *enclaveKey;
@property (nonatomic) NSData *contactsKey;
@property (nonatomic) CKRSAPrivateKey *userPrivateKey;
@property (nonatomic) NSString *userPrivateKeyPEM;
@property (nonatomic) CKRSAPublicKey *userPublicKey;
@property (nonatomic) NSString *userPublicKeyPEM;

// Authentication parameters
@property (nonatomic) NSData *clientAuthRandom;
@property (nonatomic) NSData *serverAuthRandom;

- (instancetype)init;

@end
