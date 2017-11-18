//
//  NewAccountCreator.m
//  pippip-native-ios
//
//  Created by Steve Brenneis on 10/10/17.
//  Copyright © 2017 seComm. All rights reserved.
//

#import "NewAccountCreator.h"
#import "ParameterGenerator.h"
#import "AccountRequestStep.h"
#import "AccountFinishStep.h"

@interface NewAccountCreator ()
{
    HomeViewController *homeController;
}

@end

@implementation NewAccountCreator

- (instancetype)initWithViewController:(HomeViewController *)controller {
    self = [super init];

    homeController = controller;
    return self;

}

- (void)createAccount:(NSString *)accountName withPassphrase:(NSString *)passphrase {

    // Generate the user parameters.
    [homeController updateStatus:@"Generating user data"];
    ParameterGenerator *generator = [[ParameterGenerator alloc] init];
    [generator generateParameters:accountName];
    _sessionState = generator;

    // Set up processing steps.
    _firstStep = [[AccountRequestStep alloc] initWithState:_sessionState
                                        withViewController:homeController];
    _nextStep = nil;

    // Start the session.
    [homeController updateStatus:@"Contacting the message server"];
    _session = [[RESTSession alloc] init];
    [_session startSession:self];

}

- (void)sessionComplete:(BOOL)success {
    
}

// This will be called after the new account request completes
- (void)stepComplete:(BOOL)success {

    if (_nextStep == nil) {
        if (success) {
            _nextStep = [[AccountFinishStep alloc] initWithState:_sessionState
                                              withViewController:homeController];
            [homeController updateStatus:@"Finishing account creation"];
        }
        else {
            [homeController updateActivityIndicator:NO];
            NSString *status = [homeController defaultMessage];
            [homeController updateStatus:status];
        }
    }
    else {  // Next step not nil, request succeeded.
        if (success) {
            [homeController updateStatus:@"Account created. Online"];
        }
        else {
            NSString *status = [homeController defaultMessage];
            [homeController updateStatus:status];
        }
        [homeController updateActivityIndicator:NO];
        _sessionState.authenticated = success;
        [homeController authenticated:_sessionState];
    }

}

@end
