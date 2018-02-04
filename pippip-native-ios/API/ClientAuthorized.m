//
//  ClientAuthorized.m
//  pippip-native-ios
//
//  Created by Steve Brenneis on 12/6/17.
//  Copyright © 2017 seComm. All rights reserved.
//

#import "ClientAuthorized.h"

@interface ClientAuthorized ()
{
    
    SessionState *sessionState;
    
}
@end

@implementation ClientAuthorized

- (instancetype)initWithState:(SessionState *)state {
    self = [super init];
    
    sessionState = state;
    return self;
    
}

- (BOOL)processResponse:(NSDictionary *)response errorDelegate:(id<ErrorDelegate>)errorDelegate {
    
    NSString *errorStr = [response objectForKey:@"error"];
    NSNumber *authToken = [response objectForKey:@"authToken"];
    sessionState.authToken = [authToken longLongValue];
    if (errorStr != nil) {
        [errorDelegate responseError:errorStr];
        return NO;
    }

    return YES;

}

@end
