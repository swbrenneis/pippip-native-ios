//
//  EnclaveResponse.m
//  pippip-native-ios
//
//  Created by Steve Brenneis on 12/13/17.
//  Copyright © 2017 seComm. All rights reserved.
//

#import "EnclaveResponse.h"
#import "NSData+HexEncode.h"
#import "CKGCMCodec.h"

@interface EnclaveResponse ()
{
    SessionState *sessionState;
    NSDictionary *response;
}

@end

@implementation EnclaveResponse

- (instancetype)initWithState:(SessionState *)state {
    self = [super init];
    
    sessionState = state;
    return self;
    
}

- (BOOL)processResponse:(NSDictionary*)enclaveResponse errorDelegate:(id<ErrorDelegate>)errorDelegate {
    
    NSString *responseStr = [enclaveResponse objectForKey:@"response"];
    NSString *errorStr = [enclaveResponse objectForKey:@"error"];
    if (errorStr != nil) {
        [errorDelegate responseError:errorStr];
        return NO;
    }

    if (responseStr == nil) {
        [errorDelegate responseError:@"Invalid server response"];
        return NO;
    }

    NSError *error = nil;
    NSData *responseData = [NSData dataWithHexString:responseStr withError:&error];
    if (error != nil) {
        [errorDelegate responseError:[error localizedDescription]];
        return NO;
    }
    
    CKGCMCodec *codec = [[CKGCMCodec alloc] initWithData:responseData];
    [codec decrypt:sessionState.enclaveKey withAuthData:sessionState.authData withError:&error];
    if (error != nil) {
        [errorDelegate responseError:[error localizedDescription]];
        return NO;
    }
    NSString *json = [codec getString];
    
    response = [NSJSONSerialization JSONObjectWithData:[json dataUsingEncoding:NSUTF8StringEncoding]
                                               options:NSJSONReadingMutableLeaves
                                                 error:&error];
    if (error != nil) {
        [errorDelegate responseError:[error localizedDescription]];
        return NO;
    }

    NSString *errorResponse = response[@"error"];
    if (errorResponse != nil) {
        [errorDelegate responseError:errorResponse];
        return NO;
    }

    return YES;
    
}

- (NSDictionary*) getResponse {
    return response;
}

@end
