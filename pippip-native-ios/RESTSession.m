//
//  RESTSession.m
//  pippip-native-ios
//
//  Created by Steve Brenneis on 10/10/17.
//  Copyright © 2017 seComm. All rights reserved.
//

#import "RESTSession.h"
#import "ErrorDelegate.h"
#import "PostPacket.h"
#import "RequestStep.h"
#import "SessionState.h"
#import "CKPEMCodec.h"
#import "stdio.h"

@interface RESTSession () {

    id<RequestStep> requestStep;
    id<RequestProcess> requestProcess;
    id<ErrorDelegate> errorDelegate;
    NSURLSessionConfiguration *sessionConfig;
    NSURLSession *urlSession;

}

@end

@implementation RESTSession

- (instancetype)init {
    self = [super init];

    sessionConfig = [NSURLSessionConfiguration ephemeralSessionConfiguration];
    urlSession = [NSURLSession sessionWithConfiguration:sessionConfig];
    return self;

}

- (void)startSession:(id<RequestProcess>)process {

    // Set up the first step in the exchange.
    requestProcess = process;
    requestStep = requestProcess.firstStep;
    errorDelegate = requestStep.errorDelegate;

    // Session completion block.
    void (^sessionCompletion)(NSData*, NSURLResponse*, NSError*) =
        ^(NSData *data, NSURLResponse *response, NSError *error) {
            if (error != nil) {
                [self sessionFailed:error.localizedDescription];
            }
            else {
                // Decode the response.
                NSError *jsonError;
                NSDictionary *responseJson = [NSJSONSerialization JSONObjectWithData:data
                                                                             options:NSJSONReadingMutableLeaves
                                                                               error:&jsonError];
                if (responseJson == nil) {  // Invalid JSON
                    [self sessionFailed:jsonError.localizedDescription];
                }
                else {
                    // The presence of a "Message" element indicates an API gateway error.
                    NSString *message = [responseJson objectForKey:@"message"];
                    if (message != nil) {
                        [self sessionFailed:message];
                    }
                    else {
                        [self sessionResponseComplete:responseJson];
                    }
                }
            }
        };

    // Perform the session request. The task defaults to "GET" method.
    NSURL *sessionURL = [NSURL URLWithString:@"https://pippip.secomm.cc/authenticator/session-request"];
    NSURLSessionDataTask *sessionTask = [urlSession dataTaskWithURL:sessionURL
                                                  completionHandler:sessionCompletion];
    [sessionTask resume];

}

- (void)doPost {

    void (^postCompletion)(NSData*, NSURLResponse*, NSError*) =
    ^(NSData *data, NSURLResponse *response, NSError *error) {
 
        NSString *responseJsonStr = [[NSString alloc] initWithData:data
                                                          encoding:NSUTF8StringEncoding];
        //printf("%s", [responseJsonStr cStringUsingEncoding:NSUTF8StringEncoding]);
        if (error != nil) {
            [self postFailed:error.localizedDescription];
        }
        else if (responseJsonStr.length == 0) {
            [self postFailed:@"Empty server response"];
        }
        else {
            NSError *jsonError;
            NSDictionary *responseJson = [NSJSONSerialization JSONObjectWithData:data
                                                                     options:NSJSONReadingMutableLeaves
                                                                       error:&jsonError];
            if (responseJson == nil) {
                [self postFailed:jsonError.localizedDescription];
            }
            else {
                NSString *message = [responseJson objectForKey:@"message"];
                if (message != nil) {
                    [self postFailed:message];
                }
                else {
                    [requestProcess stepComplete:YES];
                    if ([requestStep.response processResponse:responseJson errorDelegate:errorDelegate]) {
                        requestStep = requestProcess.nextStep;
                        if (requestStep != nil) {
                            errorDelegate = requestStep.errorDelegate;
                            [requestStep step:self];
                        }
                    }
                }
            }
        }
    };

    NSDictionary *packetData = [requestStep.postPacket restPacket];
    NSError *jsonError = nil;
    NSData *json = [NSJSONSerialization dataWithJSONObject:packetData
                                                   options:0
                                                     error:&jsonError];
    if (json == nil) {
        [errorDelegate postMethodError:jsonError.localizedDescription];
    }
    else {
        NSURL *postURL = [NSURL URLWithString:[requestStep.postPacket restURL]];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:postURL
                                                               cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                           timeoutInterval:[requestStep.postPacket restTimeout]];
        [request setHTTPMethod:@"POST"];
        [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
        [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [request setHTTPBody:json];
        NSURLSessionDataTask *postTask = [urlSession dataTaskWithRequest:request
                                                   completionHandler:postCompletion];
        [postTask resume];
    }
    
}

- (void)postFailed:(NSString*)error {

    [errorDelegate postMethodError:error];
    [requestProcess stepComplete:NO];

}

- (void)sessionFailed:(NSString*)error {

    [errorDelegate sessionError:error];
    [requestProcess sessionComplete:NO];

}

- (void)sessionResponseComplete:(NSDictionary*)sessionResponse {

        NSString *error = [sessionResponse objectForKey:@"error"];         // Session request error.
        if (error != nil) {
            [errorDelegate sessionError:error];
            [requestProcess sessionComplete:NO];
        }
        else {
            NSString *sessionId = [sessionResponse objectForKey:@"sessionId"];
            NSString *serverPublicKeyPEM = [sessionResponse objectForKey:@"serverPublicKey"];
            if (sessionId == nil) {
                [self sessionFailed:@"Invalid server response, missing session ID"];
            }
            if (serverPublicKeyPEM == nil) {
                [self sessionFailed:@"Invalid server response, missing public key"];
            }
            else {
                requestProcess.sessionState.sessionId = [sessionId intValue];
                CKPEMCodec *pem = [[CKPEMCodec alloc] init];
                requestProcess.sessionState.serverPublicKey = [pem decodePublicKey:serverPublicKeyPEM];
                [requestProcess sessionComplete:YES];
                [requestStep step:self];
            }
        }
    }

@end
