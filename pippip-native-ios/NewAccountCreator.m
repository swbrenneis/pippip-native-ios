//
//  NewAccountCreator.m
//  pippip-native-ios
//
//  Created by Steve Brenneis on 10/10/17.
//  Copyright © 2017 seComm. All rights reserved.
//

#import "NewAccountCreator.h"
#import "ParameterGenerator.h"
#import "NewAccountRequest.h"
#import "NewAccountResponse.h"
#import "NewAccountFinish.h"
#import "NewAccountFinal.h"
#import "AlertErrorDelegate.h"
#import "UserVault.h"
#import "CKPEMCodec.h"

typedef enum STEP { REQUEST, FINISH } ProcessStep;

@interface NewAccountCreator ()
{

    HomeViewController *homeController;
    ProcessStep step;
    NSString *accountName;
    NSString *passPhrase;

}

@end

@implementation NewAccountCreator

@synthesize errorDelegate;
@synthesize postPacket;

- (instancetype)initWithViewController:(HomeViewController *)controller {
    self = [super init];

    homeController = controller;
    errorDelegate = [[AlertErrorDelegate alloc] initWithViewController:homeController
                                                              withTitle:@"New Account Creation Error"];
    
    return self;

}

- (void)createAccount:(NSString *)userName withPassphrase:(NSString *)passphrase {

    accountName = userName;
    passPhrase = passphrase;
    // Generate the user parameters.
    [homeController updateStatus:@"Generating user data"];
    ParameterGenerator *generator = [[ParameterGenerator alloc] init];
    [generator generateParameters:accountName];
    _sessionState = generator;

    // Start the session.
    [homeController updateStatus:@"Contacting the message server"];
    _session = [[RESTSession alloc] init];
    [_session startSession:self];

}

- (void) doFinish {

    step = FINISH;
    postPacket = [[NewAccountFinish alloc] initWithState:_sessionState];
    [homeController updateStatus:@"Finishing account creation"];
    [_session doPost];

}

// This will be called after the new account request completes
- (void)postComplete:(NSDictionary*)response {

    if (response != nil) {
        switch (step) {
            case REQUEST:
                if ([self validateResponse:response]) {
                    [self doFinish];
                }
                break;
            case FINISH:
                if ([self validateFinish:response]) {
                    [self storeVault];
                    [homeController updateStatus:@"Account created. Online"];
                    [homeController updateActivityIndicator:NO];
                    _sessionState.authenticated = YES;
                    [homeController authenticated:_sessionState];
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
            _sessionState.sessionId = [sessionId intValue];
            CKPEMCodec *pem = [[CKPEMCodec alloc] init];
            _sessionState.serverPublicKey = [pem decodePublicKey:serverPublicKeyPEM];
            step = REQUEST;
            postPacket = [[NewAccountRequest alloc] initWithState:_sessionState];
            [homeController updateStatus:@"Requesting account"];
            [_session doPost];
        }
    }

}

- (void) storeVault {

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docPath = [paths objectAtIndex:0];
    NSString *vaultsPath = [docPath stringByAppendingPathComponent:@"PippipVaults"];
    NSString *vaultPath = [vaultsPath stringByAppendingPathComponent:accountName];

    UserVault *vault = [[UserVault alloc] initWithState:_sessionState];
    NSData *vaultData = [vault encode:passPhrase];

    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager createDirectoryAtPath:vaultsPath
           withIntermediateDirectories:NO
                            attributes:nil
                                 error:nil];
    [vaultData writeToFile:vaultPath atomically:YES];

}

- (BOOL) validateFinish:(NSDictionary*)response {

    NewAccountFinal *accountFinal = [[NewAccountFinal alloc] initWithState:_sessionState];
    return [accountFinal processResponse:response
                           errorDelegate:errorDelegate];

}

- (BOOL) validateResponse:(NSDictionary*)response {

    NewAccountResponse *accountResponse = [[NewAccountResponse alloc] initWithState:_sessionState];
    return [accountResponse processResponse:response
                              errorDelegate:errorDelegate];

}

@end
