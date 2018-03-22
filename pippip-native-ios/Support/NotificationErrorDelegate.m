//
//  NotificationErrorDelegate.m
//  pippip-native-ios
//
//  Created by Steve Brenneis on 3/21/18.
//  Copyright © 2018 seComm. All rights reserved.
//

#import "NotificationErrorDelegate.h"

@interface NotificationErrorDelegate ()
{
    UIAlertController *alert;
    NSMutableDictionary *info;
}

@end

@implementation NotificationErrorDelegate

- (instancetype)initWithTitle:(NSString*)title {
    self = [super init];

    alert = [UIAlertController alertControllerWithTitle:title
                                                message:@""
                                         preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                       style:UIAlertActionStyleDefault
                                                     handler:nil];
    [alert addAction:okAction];
    info = [NSMutableDictionary dictionary];
    info[@"alert"] = alert;

    return self;

}

- (void)getMethodError:(NSString*)error {

    alert.message = error;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"PresentAlert" object:nil userInfo:info];

}

- (void)postMethodError:(NSString*)error {

    alert.message = error;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"PresentAlert" object:nil userInfo:info];

}

- (void)responseError:(NSString*)error {

    alert.message = error;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"PresentAlert" object:nil userInfo:info];

}

- (void)sessionError:(NSString*)error {

    alert.message = error;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"PresentAlert" object:nil userInfo:info];

}

@end
