//
//  RESTSession.m
//  pippip-native-ios
//
//  Created by Steve Brenneis on 10/10/17.
//  Copyright © 2017 seComm. All rights reserved.
//

#import "RESTSession.h"

@interface RESTSession () {

    id<SessionDelegate> sessionDelegate;
    id<RESTRequestDelegate> restDelegate;
    NSURLSessionConfiguration *sessionConfig;
    NSURLSession *urlSession;

}

@end

@implementation RESTSession

- (instancetype)initWithState:(SessionState*)state {
    self = [super init];

    _sessionState = state;
    sessionConfig = [NSURLSessionConfiguration ephemeralSessionConfiguration];
    urlSession = [NSURLSession sessionWithConfiguration:sessionConfig];
    return self;

}

- (void)startSession:(id<SessionDelegate>)delegate {

    sessionDelegate = delegate;

    void (^sessionCompletion)(NSData*, NSURLResponse*, NSError*) =
        ^(NSData *data, NSURLResponse *response, NSError *error) {
            if (error != nil) {
                [sessionDelegate sessionError:error.localizedDescription];
            }
            else {
                [self sessionResponseComplete:data];
            }
        };

    NSURL *sessionURL = [NSURL URLWithString:@"https://pippip.io:2880/io.pippip.rest/SessionRequest"];
    NSURLSessionDataTask *sessionTask = [urlSession dataTaskWithURL:sessionURL
                                                  completionHandler:sessionCompletion];
    [sessionTask resume];

}

- (void)doPost:(id<PostPacket>)packet withDelegate:(id<RESTRequestDelegate>)delegate {

    restDelegate = delegate;

    void (^postCompletion)(NSData*, NSURLResponse*, NSError*) =
    ^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error != nil) {
            [restDelegate restError:error.localizedDescription];
        }
        else {
            NSError *jsonError;
            NSDictionary *response = [NSJSONSerialization JSONObjectWithData:data
                                                                     options:NSJSONReadingMutableLeaves
                                                                       error:&jsonError];
            if (response == nil) {
                [restDelegate restError:jsonError.localizedDescription];
            }
            else {
                [restDelegate restResponse:response];
            }
        }
    };

    NSDictionary *packetData = [packet restPacket];
    NSError *jsonError;
    NSData *json = [NSJSONSerialization dataWithJSONObject:packetData
                                                   options:0
                                                     error:&jsonError];
    if (json == nil) {
        [restDelegate restError:jsonError.localizedDescription];
    }
    else {
        NSURL *postURL = [NSURL URLWithString:[packet restURL]];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:postURL
                                                               cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                           timeoutInterval:[packet restTimeout]];
        request.HTTPBody = json;
        request.HTTPMethod = @"POST";
        NSURLSessionDataTask *postTask = [urlSession dataTaskWithURL:postURL
                                                   completionHandler:postCompletion];
        [postTask resume];
    }
    
}

- (void)sessionResponseComplete:(NSData*)sessionResponse {

    // Extract session ID or error from response, and respond to delegate.
    NSError *jsonError;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:sessionResponse
                                                                options:NSJSONReadingMutableLeaves
                                                                  error:&jsonError];
    if (json == nil) {
        [sessionDelegate sessionError:jsonError.localizedDescription];
    }
    else {
        NSString *error = [json objectForKey:@"error"];
        if (error != nil) {
            [sessionDelegate sessionError:error];
        }
        else {
            NSString *sessionId = [json objectForKey:@"sessionId"];
            if (sessionId == nil) {
                [sessionDelegate sessionError:@"Invalid server response"];
            }
            else {
                _sessionState.sessionId = [sessionId intValue];
                [sessionDelegate sessionComplete];
            }
        }
    }

}

@end
