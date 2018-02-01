//
//  NewAccountFinal.m
//  pippip-native-ios
//
//  Created by Steve Brenneis on 10/25/17.
//  Copyright © 2017 seComm. All rights reserved.
//

#import "NewAccountFinal.h"

@interface NewAccountFinal ()
{
    SessionState *sessionState;
}
@end

@implementation NewAccountFinal

- (instancetype)initWithState:(SessionState*)state {
    self = [super init];
    
    sessionState = state;
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
