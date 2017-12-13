//
//  NewAccountCreator.m
//  pippip-native-ios
//
//  Created by Steve Brenneis on 10/10/17.
//  Copyright © 2017 seComm. All rights reserved.
//

#import "NewAccountCreator.h"
#import "RESTSession.h"
#import "NewAccountRequest.h"
#import "NewAccountResponse.h"
#import "NewAccountFinish.h"
#import "NewAccountFinal.h"
#import "AlertErrorDelegate.h"
#import "AccountManager.h"
#import "CKPEMCodec.h"

typedef enum STEP { REQUEST, FINISH } ProcessStep;

@interface NewAccountCreator ()
{

    ProcessStep step;
    RESTSession *session;

}

@property (weak, nonatomic) AccountManager *accountManager;
@property (weak, nonatomic) HomeViewController *viewController;

@end

@implementation NewAccountCreator

@synthesize errorDelegate;
@synthesize postPacket;

- (instancetype)initWithViewController:(HomeViewController *)controller {
    self = [super init];

    _viewController = controller;
    errorDelegate = [[AlertErrorDelegate alloc] initWithViewController:_viewController
                                                              withTitle:@"New Account Creation Error"];
    session = [[RESTSession alloc] init];
    session.requestProcess = self;

    return self;

}

- (void)createAccount:(AccountManager*)manager {

    _accountManager = manager;
    [_viewController updateStatus:@"Generating user data"];
    [_accountManager generateParameters];
    // Start the session.
    [_viewController updateStatus:@"Contacting the message server"];
    [session startSession];

}

- (void) doFinish {

    step = FINISH;
    postPacket = [[NewAccountFinish alloc] initWithState:_accountManager.sessionState];
    [_viewController updateStatus:@"Finishing account creation"];
    [session doPost];

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
                    [_accountManager storeVault];
                    [_accountManager setDefaultConfig];
                    [_accountManager storeConfig];
                    _accountManager.sessionState.authenticated = YES;
                    [_viewController authenticated:@"Account created. Online"];
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
            _accountManager.sessionState.sessionId = [sessionId intValue];
            CKPEMCodec *pem = [[CKPEMCodec alloc] init];
            _accountManager.sessionState.serverPublicKey = [pem decodePublicKey:serverPublicKeyPEM];
            step = REQUEST;
            postPacket = [[NewAccountRequest alloc] initWithState:_accountManager.sessionState];
            [_viewController updateStatus:@"Requesting account"];
            [session doPost];
        }
    }

}

- (BOOL) validateFinish:(NSDictionary*)response {

    NewAccountFinal *accountFinal = [[NewAccountFinal alloc] initWithState:_accountManager.sessionState];
    return [accountFinal processResponse:response
                           errorDelegate:errorDelegate];

}

- (BOOL) validateResponse:(NSDictionary*)response {

    NewAccountResponse *accountResponse = [[NewAccountResponse alloc] initWithState:_accountManager.sessionState];
    return [accountResponse processResponse:response
                              errorDelegate:errorDelegate];

}

@end
