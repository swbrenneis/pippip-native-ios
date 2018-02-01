//
//  Authenticator.m
//  pippip-native-ios
//
//  Created by Steve Brenneis on 12/1/17.
//  Copyright © 2017 seComm. All rights reserved.
//

#import "Authenticator.h"
#import "AppDelegate.h"
#import "AccountSession.h"
#import "SessionState.h"
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
    SessionState *sessionState;
}

@property (weak, nonatomic) HomeViewController *viewController;
@property (weak, nonatomic) RESTSession *session;

@end

@implementation Authenticator

@synthesize errorDelegate;
@synthesize postPacket;

- (instancetype)initWithViewController:(HomeViewController *)controller withRESTSession:(RESTSession *)restSession {
    self = [super init];
    
    _viewController = controller;
    errorDelegate = [[AlertErrorDelegate alloc] initWithViewController:_viewController
                                                             withTitle:@"Authentication Error"];
    _session = restSession;

    return self;
    
}

- (void)authenticate:(NSString*)accountName withPassphrase:(NSString *)passphrase {

    NSError *error = nil;
    [self loadSessionState:accountName withPassphrase:passphrase withError:&error];
    if (error == nil) {
        step = REQUEST;
        // Start the session.
        [_viewController updateStatus:@"Contacting the message server"];
        [_session startSession:self];
    }
    else {
        [errorDelegate sessionError:@"Invalid passphrase"];
    }

}

- (void)authenticated {

    sessionState.authenticated = YES;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        AppDelegate *delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
        [delegate.accountManager loadConfig:sessionState.currentAccount];
        [delegate.accountSession startSession:sessionState];
        [delegate.accountSession.contactManager loadContacts];
        [delegate.accountSession.messageManager loadMessages];
    });

}

- (void)doAuthorized {

    step = AUTHORIZED;
    postPacket = [[ServerAuthorized alloc] initWithState:sessionState];
    [_viewController updateStatus:@"Authorizing server"];
    [_session queuePost:self];
    
}

- (void)doChallenge {

    step = CHALLENGE;
    postPacket = [[ClientAuthChallenge alloc] initWithState:sessionState];
    [_viewController updateStatus:@"Performing challenge"];
    [_session queuePost:self];

}

- (void)loadSessionState:(NSString*)accountName withPassphrase:(NSString*)passphrase withError:(NSError**)error {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docPath = [paths objectAtIndex:0];
    NSString *vaultsPath = [docPath stringByAppendingPathComponent:@"PippipVaults"];
    NSString *vaultPath = [vaultsPath stringByAppendingPathComponent:accountName];
    NSData *vaultData = [NSData dataWithContentsOfFile:vaultPath];
    
    sessionState = [[SessionState alloc] init];
    UserVault *vault = [[UserVault alloc] initWithState:sessionState];
    [vault decode:vaultData withPassword:passphrase withError:error];
    sessionState.currentAccount = accountName;
    
}

/*
 * This is invoked from the main thread.
 */
- (void) logout {

    AppDelegate *delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    sessionState = delegate.accountSession.sessionState;
    [delegate.accountSession endSession];
    step = LOGOUT;
    postPacket = [[Logout alloc] initWithState:sessionState];
    [_viewController updateStatus:@"Logging out"];
    [_session queuePost:self];

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
                    [self authenticated];
                    [_viewController authenticated:@"Account authenticated. Online"];
                }
                break;
            case LOGOUT:
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
            sessionState.sessionId = [sessionId intValue];
            CKPEMCodec *pem = [[CKPEMCodec alloc] init];
            sessionState.serverPublicKey = [pem decodePublicKey:serverPublicKeyPEM];
            step = REQUEST;
            postPacket = [[AuthenticationRequest alloc] initWithState:sessionState];
            [_viewController updateStatus:@"Requesting authentication"];
            [_session queuePost:self];
        }
    }
    
}

- (BOOL) validateAuth:(NSDictionary*)response {
    
    ClientAuthorized *authorized = [[ClientAuthorized alloc] initWithState:sessionState];
    return [authorized processResponse:response
                            errorDelegate:errorDelegate];
    
}

- (BOOL) validateChallenge:(NSDictionary*)response {
    
    ServerAuthChallenge *authChallenge = [[ServerAuthChallenge alloc] initWithState:sessionState];
    return [authChallenge processResponse:response
                            errorDelegate:errorDelegate];
    
}

- (BOOL) validateResponse:(NSDictionary*)response {
    
    AuthenticationResponse *authResponse = [[AuthenticationResponse alloc] initWithState:sessionState];
    return [authResponse processResponse:response
                           errorDelegate:errorDelegate];
    
}

@end
