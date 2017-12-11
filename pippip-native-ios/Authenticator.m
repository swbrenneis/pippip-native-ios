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
#import "ClientAuthorized.h"
#import "Logout.h"
#import "CKPEMCodec.h"

typedef enum STEP { REQUEST, CHALLENGE, AUTHORIZED, LOGOUT } ProcessStep;

@interface Authenticator ()
{

    ProcessStep step;
    
}

@property (weak, nonatomic) SessionState *sessionState;
@property (weak, nonatomic) AccountManager *accountManager;
@property (weak, nonatomic) HomeViewController *viewController;

@end

@implementation Authenticator

@synthesize errorDelegate;
@synthesize postPacket;

- (instancetype)initWithViewController:(HomeViewController *)controller {
    self = [super init];
    
    _viewController = controller;
    errorDelegate = [[AlertErrorDelegate alloc] initWithViewController:_viewController
                                                             withTitle:@"Authentication Error"];
    
    return self;
    
}

- (void) authenticate:(AccountManager *)manager {

    _accountManager = manager;
    NSError *error = nil;
    [_accountManager loadSessionState:&error];
    if (error == nil) {
        step = REQUEST;
        // Start the session.
        [_viewController updateStatus:@"Contacting the message server"];
        _session = [[RESTSession alloc] init];
        [_session startSession:self];
    }
    else {
        [errorDelegate sessionError:@"Invalid passphrase"];
    }

}

- (void) doAuthorized {

    step = AUTHORIZED;
    postPacket = [[ServerAuthorized alloc] initWithState:_accountManager.sessionState];
    [_viewController updateStatus:@"Authorizing server"];
    [_session doPost];
    
}

- (void)doChallenge {

    step = CHALLENGE;
    postPacket = [[ClientAuthChallenge alloc] initWithState:_accountManager.sessionState];
    [_viewController updateStatus:@"Performing challenge"];
    [_session doPost];
    
}

- (void) logout:(AccountManager*)accountManager {

    step = LOGOUT;
    postPacket = [[Logout alloc] initWithState:accountManager.sessionState];
    [_viewController updateStatus:@"Logging out"];
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
                    _accountManager.sessionState.authenticated = YES;
                    [_viewController authenticated:@"Account authenticated. Online"];
                }
                break;
            case LOGOUT:
                // Nothing to do here.
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
            _accountManager.sessionState.sessionId = [sessionId intValue];
            CKPEMCodec *pem = [[CKPEMCodec alloc] init];
            _accountManager.sessionState.serverPublicKey = [pem decodePublicKey:serverPublicKeyPEM];
            step = REQUEST;
            postPacket = [[AuthenticationRequest alloc] initWithState:_accountManager.sessionState];
            [_viewController updateStatus:@"Requesting authentication"];
            [_session doPost];
        }
    }
    
}

- (BOOL) validateAuth:(NSDictionary*)response {
    
    ClientAuthorized *authorized = [[ClientAuthorized alloc] initWithState:_accountManager.sessionState];
    return [authorized processResponse:response
                            errorDelegate:errorDelegate];
    
}

- (BOOL) validateChallenge:(NSDictionary*)response {
    
    ServerAuthChallenge *authChallenge = [[ServerAuthChallenge alloc] initWithState:_accountManager.sessionState];
    return [authChallenge processResponse:response
                            errorDelegate:errorDelegate];
    
}

- (BOOL) validateResponse:(NSDictionary*)response {
    
    AuthenticationResponse *authResponse = [[AuthenticationResponse alloc] initWithState:_accountManager.sessionState];
    return [authResponse processResponse:response
                           errorDelegate:errorDelegate];
    
}

@end
