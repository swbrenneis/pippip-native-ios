//
//  Authenticator.m
//  pippip-native-ios
//
//  Created by Steve Brenneis on 12/1/17.
//  Copyright © 2017 seComm. All rights reserved.
//

#import "Authenticator.h"
#import "AlertErrorDelegate.h"
#import "UserVault.h"
#import "AuthenticationRequest.h"
#import "CKPEMCodec.h"

typedef enum STEP { REQUEST, CHALLENGE, AUTHORIZED } ProcessStep;

@interface Authenticator ()
{

    HomeViewController *homeController;
    ProcessStep step;
    AccountManager *accountManager;
    
}
@end

@implementation Authenticator

@synthesize errorDelegate;
@synthesize postPacket;

- (instancetype)initWithViewController:(HomeViewController *)controller {
    self = [super init];
    
    homeController = controller;
    errorDelegate = [[AlertErrorDelegate alloc] initWithViewController:homeController
                                                             withTitle:@"Authentication Error"];
    
    return self;
    
}

- (void) authenticate:(AccountManager *)manager {

    accountManager = manager;
    NSError *error = nil;
    [accountManager loadSessionState:&error];
    if (error == nil) {
        step = REQUEST;
        // Start the session.
        [homeController updateStatus:@"Contacting the message server"];
        _session = [[RESTSession alloc] init];
        [_session startSession:self];
    }
    else {
        [errorDelegate sessionError:@"Invalid passphrase"];
    }

}

- (void)sessionComplete:(NSDictionary*)response {
    
    if (response != nil) {
        NSString *sessionId = [response objectForKey:@"sessionId"];
        NSString *serverPublicKeyPEM = [response objectForKey:@"serverPublicKey"];
        if (sessionId == nil) {
            [errorDelegate sessionError:@"Invalid server response, missing session ID"];
        }
        else if (serverPublicKeyPEM == nil) {
            [errorDelegate sessionError:@"Invalid server response, missing public key"];
        }
        else {
            accountManager.sessionState.sessionId = [sessionId intValue];
            CKPEMCodec *pem = [[CKPEMCodec alloc] init];
            accountManager.sessionState.serverPublicKey = [pem decodePublicKey:serverPublicKeyPEM];
            step = REQUEST;
            postPacket = [[AuthenticationRequest alloc] initWithState:accountManager.sessionState];
            [homeController updateStatus:@"Requesting authentication"];
            [_session doPost];
        }
    }
    
}


@end
