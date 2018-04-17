//
//  Authenticator.m
//  pippip-native-ios
//
//  Created by Steve Brenneis on 12/1/17.
//  Copyright © 2017 seComm. All rights reserved.
//

#import "pippip_native_ios-Swift.h"

#import "Authenticator.h"
#import "ApplicationSingleton.h"
#import "AccountSession.h"
#import "AccountManager.h"
#import "AuthenticationRequest.h"
#import "AuthenticationResponse.h"
#import "ClientAuthChallenge.h"
#import "ServerAuthChallenge.h"
#import "ServerAuthorized.h"
#import "ClientAuthorized.h"
#import "Logout.h"
#import "Notifications.h"
#import "CKPEMCodec.h"

typedef enum STEP { REQUEST, CHALLENGE, AUTHORIZED, LOGOUT } ProcessStep;

@interface Authenticator ()
{
    ProcessStep step;
    SessionState *sessionState;
    SessionStateActual *sessionStateActual;

}

@property (weak, nonatomic) AuthViewController *viewController;
@property (weak, nonatomic) RESTSession *session;

@end

@implementation Authenticator

@synthesize errorDelegate;
@synthesize postPacket;

- (instancetype)init {
    self = [super init];
    
    errorDelegate = [[NotificationErrorDelegate alloc] init:@"Authentication Error"];
    _session = [ApplicationSingleton instance].restSession;
    sessionState = [[SessionState alloc] init];
    sessionStateActual = [[SessionStateActual alloc] init];
    [sessionState setState:sessionStateActual];

    return self;
    
}

- (instancetype)initForLogout {
    self = [super init];
    
    errorDelegate = [[NotificationErrorDelegate alloc] init:@"Authentication Error"];
    _session = [ApplicationSingleton instance].restSession;
    sessionState = [[SessionState alloc] init];
    return self;
    
}

- (void)authenticate:(NSString*)accountName withPassphrase:(NSString *)passphrase {

    NSError *error = nil;
    [self loadSessionState:accountName withPassphrase:passphrase withError:&error];
    NSMutableDictionary *info = [NSMutableDictionary dictionary];
    info[@"progress"] = [NSNumber numberWithFloat:0.2];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateProgress" object:nil userInfo:info];
    if (error == nil) {
        step = REQUEST;
        // Start the session.
        [_session startSession:self];
    }
    else {
        [errorDelegate sessionError:@"Invalid passphrase"];
    }

}

- (void)authenticated {

    sessionStateActual.authenticated = true;

    [[NSNotificationCenter defaultCenter] postNotificationName:AUTHENTICATED object:nil];

}

- (void)doAuthorized {

    step = AUTHORIZED;
    postPacket = [[ServerAuthorized alloc] init];
    [_session queuePost:self];
    
}

- (void)doChallenge {

    step = CHALLENGE;
    postPacket = [[ClientAuthChallenge alloc] init];
    [_session queuePost:self];

}

- (void)loadSessionState:(NSString*)accountName withPassphrase:(NSString*)passphrase withError:(NSError**)error {

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docPath = [paths objectAtIndex:0];
    NSString *vaultsPath = [docPath stringByAppendingPathComponent:@"PippipVaults"];
    NSString *vaultPath = [vaultsPath stringByAppendingPathComponent:accountName];
    NSData *vaultData = [NSData dataWithContentsOfFile:vaultPath];

    UserVault *vault = [[UserVault alloc] initWith:sessionStateActual];
    [vault decode:vaultData passphrase:passphrase error:error];
    sessionStateActual.accountName = accountName;
    
}

- (void)localAuthenticate:(NSString *)accountName withPassphrase:(NSString *)passphrase {
    
    NSError *error = nil;
    [self loadSessionState:accountName withPassphrase:passphrase withError:&error];
    if (error == nil) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"Authenticated" object:sessionState];
    }
    else {
        [errorDelegate sessionError:@"Invalid passphrase"];
    }

}

/*
 * This is invoked from the main thread.
 */
- (void)logout {

    step = LOGOUT;
    postPacket = [[Logout alloc] init];
    [_session queuePost:self];
    [[NSNotificationCenter defaultCenter] postNotificationName:SESSION_ENDED object:nil];

}

- (void)postComplete:(NSDictionary*)response {
    
    if (response != nil) {
        switch (step) {
            case REQUEST:
                if ([self validateResponse:response]) {
                    NSMutableDictionary *info = [NSMutableDictionary dictionary];
                    info[@"progress"] = [NSNumber numberWithFloat:0.6];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateProgress"
                                                                        object:nil userInfo:info];

                    [self doChallenge];
                }
                break;
            case CHALLENGE:
                if ([self validateChallenge:response]) {
                    NSMutableDictionary *info = [NSMutableDictionary dictionary];
                    info[@"progress"] = [NSNumber numberWithFloat:0.8];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateProgress"
                                                                        object:nil userInfo:info];
                    [self doAuthorized];
                }
                break;
            case AUTHORIZED:
                if ([self validateAuth:response]) {
                    NSMutableDictionary *info = [NSMutableDictionary dictionary];
                    info[@"progress"] = [NSNumber numberWithFloat:1.0];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateProgress" object:nil userInfo:info];

                    [self authenticated];
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
            postPacket = [[AuthenticationRequest alloc] init];
            [_session queuePost:self];
            NSMutableDictionary *info = [NSMutableDictionary dictionary];
            info[@"progress"] = [NSNumber numberWithFloat:0.4];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateProgress" object:nil userInfo:info];

        }
    }
    
}

- (BOOL) validateAuth:(NSDictionary*)response {
    
    ClientAuthorized *authorized = [[ClientAuthorized alloc] init];
    return [authorized processResponse:response
                            errorDelegate:errorDelegate];
    
}

- (BOOL) validateChallenge:(NSDictionary*)response {
    
    ServerAuthChallenge *authChallenge = [[ServerAuthChallenge alloc] init];
    return [authChallenge processResponse:response
                            errorDelegate:errorDelegate];
    
}

- (BOOL) validateResponse:(NSDictionary*)response {
    
    AuthenticationResponse *authResponse = [[AuthenticationResponse alloc] init];
    return [authResponse processResponse:response
                           errorDelegate:errorDelegate];
    
}

@end
