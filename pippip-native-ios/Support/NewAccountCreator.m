//
//  NewAccountCreator.m
//  pippip-native-ios
//
//  Created by Steve Brenneis on 10/10/17.
//  Copyright © 2017 seComm. All rights reserved.
//

#import "NewAccountCreator.h"
#import "NewAccountRequest.h"
#import "NewAccountResponse.h"
#import "NewAccountFinish.h"
#import "NewAccountFinal.h"
#import "LoggingErrorDelegate.h"
#import "ParameterGenerator.h"
#import "ApplicationSingleton.h"
#import "AccountSession.h"
#import "UserVault.h"
#import "CKPEMCodec.h"

typedef enum STEP { REQUEST, FINISH } ProcessStep;

@interface NewAccountCreator ()
{
    ProcessStep step;
    SessionState *sessionState;
    NSString *passphrase;
}

@property (weak, nonatomic) RESTSession *session;

@end

@implementation NewAccountCreator

@synthesize errorDelegate;
@synthesize postPacket;

- (instancetype)init {
    self = [super init];

    errorDelegate = [[LoggingErrorDelegate alloc] init];
    _session = [ApplicationSingleton instance].restSession;

    return self;

}

- (void)accountCreated {

    [self storeVault];
    sessionState.authenticated = YES;
    ApplicationSingleton *app = [ApplicationSingleton instance];
    [app.accountManager loadConfig:sessionState.currentAccount];
    [app.accountSession startSession:sessionState];

    [[NSNotificationCenter defaultCenter] postNotificationName:@"Authenticated" object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"NewSession" object:sessionState];
    
}

- (void)createAccount:(NSString*)accountName withPassphrase:(NSString *)pass {

    passphrase = pass;
    ParameterGenerator *generator = [[ParameterGenerator alloc] init];
    [generator generateParameters:accountName];
    NSMutableDictionary *info = [NSMutableDictionary dictionary];
    info[@"progress"] = [NSNumber numberWithFloat:0.25];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateProgress" object:nil userInfo:info];
    sessionState = generator;
    // Start the session.
    [_session startSession:self];

}

- (void) doFinish {

    step = FINISH;
    postPacket = [[NewAccountFinish alloc] initWithState:sessionState];
    [_session queuePost:self];

}

// This will be called after the new account request completes
- (void)postComplete:(NSDictionary*)response {

    if (response != nil) {
        switch (step) {
            case REQUEST:
                if ([self validateResponse:response]) {
                    NSMutableDictionary *info = [NSMutableDictionary dictionary];
                    info[@"progress"] = [NSNumber numberWithFloat:0.75];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateProgress"
                                                                        object:nil userInfo:info];
                    [self doFinish];
                }
                break;
            case FINISH:
                if ([self validateFinish:response]) {
                    NSMutableDictionary *info = [NSMutableDictionary dictionary];
                    info[@"progress"] = [NSNumber numberWithFloat:1.0];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateProgress"
                                                                        object:nil userInfo:info];
                    [self accountCreated];
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
            NSMutableDictionary *info = [NSMutableDictionary dictionary];
            info[@"progress"] = [NSNumber numberWithFloat:0.5];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateProgress" object:nil userInfo:info];
            sessionState.sessionId = [sessionId intValue];
            CKPEMCodec *pem = [[CKPEMCodec alloc] init];
            sessionState.serverPublicKey = [pem decodePublicKey:serverPublicKeyPEM];
            step = REQUEST;
            postPacket = [[NewAccountRequest alloc] initWithState:sessionState];
            [_session queuePost:self];
        }
    }

}

- (void)storeVault {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docPath = [paths objectAtIndex:0];
    NSString *vaultsPath = [docPath stringByAppendingPathComponent:@"PippipVaults"];
    NSString *vaultPath = [vaultsPath stringByAppendingPathComponent:sessionState.currentAccount];
    
    UserVault *vault = [[UserVault alloc] initWithState:sessionState];
    NSData *vaultData = [vault encode:passphrase];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager createDirectoryAtPath:vaultsPath
           withIntermediateDirectories:NO
                            attributes:nil
                                 error:nil];
    [vaultData writeToFile:vaultPath atomically:YES];
    
}

- (BOOL) validateFinish:(NSDictionary*)response {

    NewAccountFinal *accountFinal = [[NewAccountFinal alloc] initWithState:sessionState];
    return [accountFinal processResponse:response
                           errorDelegate:errorDelegate];

}

- (BOOL) validateResponse:(NSDictionary*)response {

    NewAccountResponse *accountResponse = [[NewAccountResponse alloc] initWithState:sessionState];
    return [accountResponse processResponse:response
                              errorDelegate:errorDelegate];

}

@end
