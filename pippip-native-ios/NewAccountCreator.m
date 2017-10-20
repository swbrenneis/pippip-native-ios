//
//  NewAccountCreator.m
//  pippip-native-ios
//
//  Created by Steve Brenneis on 10/10/17.
//  Copyright © 2017 seComm. All rights reserved.
//

#import "NewAccountCreator.h"
#import "RESTResponse.h"
#import "ParameterGenerator.h"
#import "RESTSession.h"
#import "NewAccountRequest.h"
#import "NewAccountResponse.h"

@interface NewAccountCreator ()
{
    HomeViewController *homeController;
    RESTSession *session;
    id<RESTResponse> restResponse;
}

@end

@implementation NewAccountCreator

- (instancetype)initWithController:(HomeViewController *)controller {
    self = [super init];

    homeController = controller;
    return self;

}

- (void)createAccount:(NSString *)accountName withPassphrase:(NSString *)passphrase {

    [homeController updateStatus:@"Generating user data"];
    ParameterGenerator *generator = [[ParameterGenerator alloc] init];
    [generator generateParameters:accountName];
    _sessionState = generator;
    [homeController updateStatus:@"Contacting the message server"];
    session = [[RESTSession alloc] initWithState:generator];
    [session startSession:self];

}

- (void)doAccountRequest {
    
}

- (void)restError:(NSString*)error {

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Message Server Error"
                                                                   message:error
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Ok"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction *action){}];
    [alert addAction:okAction];
    [homeController presentViewController:alert animated:YES completion:nil];

}

- (void)responseComplete:(NSDictionary*)response {

    [restResponse processResponse:response];

}

- (void)errorResponse:(NSString *)error {

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Pippip Request Error"
                                                                   message:error
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Ok"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction *action){}];
    [alert addAction:okAction];
    [homeController presentViewController:alert animated:YES completion:nil];
    
}

- (void)sessionComplete {

    NewAccountRequest *request = [[NewAccountRequest alloc] initWithState:_sessionState];
    NewAccountResponse *response = [[NewAccountResponse alloc] initWithState:_sessionState
                                                            responseDelegate:self];
    [session doPost:request withDelegate:response];
    
}

- (void)sessionError:(NSString*)error {

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Message Server Error"
                                                                   message:error
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Ok"
                                                       style:UIAlertActionStyleDefault
                                                     handler:nil];
    [alert addAction:okAction];
    [homeController presentViewController:alert animated:YES completion:nil];

}

@end
