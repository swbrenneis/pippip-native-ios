//
//  NewAccountFinal.m
//  pippip-native-ios
//
//  Created by Steve Brenneis on 10/25/17.
//  Copyright © 2017 seComm. All rights reserved.
//

#import "NewAccountFinal.h"
#import "pippip_native_ios-Swift.h"

@interface xNewAccountFinal ()
{
    SessionState *sessionState;
}
@end

@implementation xNewAccountFinal

- (instancetype)init {
    self = [super init];
    
    sessionState = [[SessionState alloc] init];
    return self;
}

- (BOOL)processResponse:(NSDictionary *)response errorDelegate:(id<ErrorDelegate>)errorDelegate {
    
    NSString *errorStr = [response objectForKey:@"error"];
    if (errorStr != nil) {
        [errorDelegate responseError:errorStr];
        return NO;
    }
    else {
        NSString *tokenStr = [response objectForKey:@"authToken"];
        sessionState.authToken = [tokenStr longLongValue];
        return YES;
    }
    
}

@end
