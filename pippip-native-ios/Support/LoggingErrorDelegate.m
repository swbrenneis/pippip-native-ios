//
//  LoggingErrorDelegate.m
//  pippip-native-ios
//
//  Created by Steve Brenneis on 1/26/18.
//  Copyright © 2018 seComm. All rights reserved.
//

#import "LoggingErrorDelegate.h"

@implementation LoggingErrorDelegate

- (void)getMethodError:(NSString*)error {

    NSLog(@"GET method error: %@", error);

}

- (void)postMethodError:(NSString*)error {

    NSLog(@"POST method error: %@", error);

}

- (void)responseError:(NSString*)error {

    NSLog(@"Response error: %@", error);

}

- (void)sessionError:(NSString*)error {

    NSLog(@"Session error: %@", error);

}

@end
