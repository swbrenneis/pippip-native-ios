//
//  ErrorDelegateAlertController.m
//  pippip-native-ios
//
//  Created by Steve Brenneis on 10/20/17.
//  Copyright © 2017 seComm. All rights reserved.
//

#import "AlertErrorDelegate.h"

@interface AlertErrorDelegate ()
{
    UIAlertController *alert;
    UIViewController *view;
}

@end

@implementation AlertErrorDelegate

- (instancetype)initWithViewController:(UIViewController *)viewController withTitle:(NSString*)title {
    self = [super init];

    view = viewController;
    alert = [UIAlertController alertControllerWithTitle:title
                                                message:@"message"
                                         preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Ok"
                                                      style:UIAlertActionStyleDefault
                                                    handler:nil];
    [alert addAction:okAction];

    return self;
}

- (void)getMethodError:(NSString*)error {

    dispatch_async(dispatch_get_main_queue(), ^{
        alert.message = error;
        [view presentViewController:alert animated:YES completion:nil];
    });
}

- (void)postMethodError:(NSString*)error {

    dispatch_async(dispatch_get_main_queue(), ^{
        alert.message = error;
        [view presentViewController:alert animated:YES completion:nil];
    });

}

- (void)sessionError:(NSString*)error {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        alert.message = error;
        [view presentViewController:alert animated:YES completion:nil];
    });

}

- (void)responseError:(NSString*)error {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        alert.message = error;
        [view presentViewController:alert animated:YES completion:nil];
    });

}

@end
