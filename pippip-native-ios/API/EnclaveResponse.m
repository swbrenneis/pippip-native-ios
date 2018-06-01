//
//  EnclaveResponse.m
//  pippip-native-ios
//
//  Created by Steve Brenneis on 12/13/17.
//  Copyright © 2017 seComm. All rights reserved.
//

#import "EnclaveResponse.h"
#import "pippip_native_ios-Swift.h"
#import "ApplicationSingleton.h"
#import "CKGCMCodec.h"

@interface EnclaveResponse ()
{
    NSDictionary *response;
    SessionState *sessionState;
}

@end

@implementation EnclaveResponse

- (instancetype)init {
    self = [super init];
    
    sessionState = [[SessionState alloc] init];
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

    NSData *responseData = [[NSData alloc] initWithBase64EncodedString:responseStr options:0];
    if (responseData == nil) {
        [errorDelegate responseError:@"Server encoding error"];
        return NO;
    }
    
    NSError *error = nil;
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
/*
 * Errors need to be processed at the recipient
    NSString *errorResponse = response[@"error"];
    if (errorResponse != nil) {
        [errorDelegate responseError:errorResponse];
        return NO;
    }
*/
    return YES;
    
}

- (NSDictionary*) getResponse {
    return response;
}

@end