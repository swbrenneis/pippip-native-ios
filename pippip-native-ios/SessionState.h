//
//  SessionState.h
//  pippip-native-ios
//
//  Created by Steve Brenneis on 10/10/17.
//  Copyright © 2017 seComm. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SessionState : NSObject

@property (nonatomic) uint32_t sessionId;
@property (nonatomic) uint64_t authToken;
@property (nonatomic) NSString *publicId;
@property (nonatomic) NSData *genpass;
@property (nonatomic) NSData *authData;
@property (nonatomic) NSData *enclaveKey;
@property (nonatomic) NSData *contactsKey;
@property (nonatomic) NSString *serverPublicKeyPEM;
@property (nonatomic) NSString *userPrivateKeyPEM;  // Public key is included in provate key PEM.

- (instancetype)init;

@end
