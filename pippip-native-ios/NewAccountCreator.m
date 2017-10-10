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

@interface NewAccountCreator ()
{
    HomeViewController *homeController;
    ParameterGenerator *generator;
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
    generator = [[ParameterGenerator alloc] init];
    [generator generateParameters:accountName];
    [self doAccountRequest];

}

- (void)doAccountRequest {
    
}

- (void)restError:(NSString*)error {

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Pippip Server Error"
                                                                   message:error
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Ok"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction *action){}];
    [alert addAction:okAction];
    [homeController presentViewController:alert animated:YES completion:nil];

}

- (void)restResponse:(NSDictionary*)response {

    [restResponse processResponse:response];

}

@end
