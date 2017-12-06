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
#import "AuthenticationResponse.h"
#import "ClientAuthChallenge.h"
#import "ServerAuthChallenge.h"
#import "ServerAuthorized.h"
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

- (void) doAuthorized {

    step = CHALLENGE;
    postPacket = [[ServerAuthorized alloc] initWithState:accountManager.sessionState];
    [homeController updateStatus:@"Authorizing server"];
    [_session doPost];
    
}

- (void)doChallenge {

    step = CHALLENGE;
    postPacket = [[ClientAuthChallenge alloc] initWithState:accountManager.sessionState];
    [homeController updateStatus:@"Performing challenge"];
    [_session doPost];
    
}

- (void)postComplete:(NSDictionary*)response {
    
    if (response != nil) {
        switch (step) {
            case REQUEST:
                if ([self validateResponse:response]) {
                    [self doChallenge];
                }
                break;
            case CHALLENGE:
                if ([self validateChallenge:response]) {
                    [self doAuthorized];
                }
                break;
            case AUTHORIZED:
                if ([self validateAuth:response]) {
                    [homeController updateStatus:@"Account authenticated. Online"];
                    [homeController updateActivityIndicator:NO];
                    accountManager.sessionState.authenticated = YES;
                    [homeController authenticated];
                }
                break;
        }
        
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

- (BOOL) validateAuth:(NSDictionary*)response {
    
    ServerAuthChallenge *authChallenge = [[ServerAuthChallenge alloc] initWithState:accountManager.sessionState];
    return [authChallenge processResponse:response
                            errorDelegate:errorDelegate];
    
}

- (BOOL) validateChallenge:(NSDictionary*)response {
    
    ServerAuthChallenge *authChallenge = [[ServerAuthChallenge alloc] initWithState:accountManager.sessionState];
    return [authChallenge processResponse:response
                            errorDelegate:errorDelegate];
    
}

- (BOOL) validateResponse:(NSDictionary*)response {
    
    AuthenticationResponse *authResponse = [[AuthenticationResponse alloc] initWithState:accountManager.sessionState];
    return [authResponse processResponse:response
                           errorDelegate:errorDelegate];
    
}

@end
