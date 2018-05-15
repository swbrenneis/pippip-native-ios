//
//  RESTSession.m
//  pippip-native-ios
//
//  Created by Steve Brenneis on 10/10/17.
//  Copyright © 2017 seComm. All rights reserved.
//

#import "RESTSession.h"
#import "pippip_native_ios-Swift.h"
#import "Notifications.h"
#import "AccountManager.h"
#import "stdio.h"

@interface RESTSession ()
{
    NSURLSessionConfiguration *sessionConfig;
    NSURLSession *urlSession;
    NSMutableArray *processes;
    NSLock *postLock;
    id<RequestProcessProtocol> currentProcess;
    BOOL sessionActive;
    NSString *sessionPath;
}

@end

@implementation RESTSession

- (instancetype)init {
    self = [super init];

    sessionConfig = [NSURLSessionConfiguration ephemeralSessionConfiguration];
    urlSession = [NSURLSession sessionWithConfiguration:sessionConfig];
    processes = [NSMutableArray array];
    postLock = [[NSLock alloc] init];
    sessionActive = NO;
    if (AccountManager.production) {
        _urlBase = @"https://pippip.secomm.cc";
        sessionPath = @"/authenticator/session-request";
    }
    else {
        _urlBase = @"https://dev.secomm.org:8443/secomm-api-rest-1.1.0";
        sessionPath = @"/session-request";
    }

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sessionEnded:)
                                                 name:SESSION_ENDED object:nil];

    return self;

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
                    [self->currentProcess postComplete:responseJson];
                }
            }
        }
        [self nextPost];
    };
    
    id<PostPacketProtocol> packet = currentProcess.postPacket;
    NSDictionary *packetData = packet.restPacket;
    NSError *jsonError = nil;
    NSData *json = [NSJSONSerialization dataWithJSONObject:packetData
                                                   options:0
                                                     error:&jsonError];
    NSString *urlString = [_urlBase stringByAppendingString:packet.restPath];
    NSURL *postURL = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:postURL
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                       timeoutInterval:packet.restTimeout];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setHTTPBody:json];
    NSURLSessionDataTask *postTask = [urlSession dataTaskWithRequest:request
                                                   completionHandler:postCompletion];
    [postTask resume];
    
}

- (void)nextPost {

    [postLock lock];
    [processes removeObjectAtIndex:0];
    if (processes.count > 0) {
        currentProcess = processes[0];
        [self doPost];
    }
    [postLock unlock];

}

- (void)postFailed:(NSString*)error {
    
    [currentProcess.errorDelegate postMethodError:error];
    [currentProcess postComplete:nil];
    
}

- (void)queuePost:(id<RequestProcessProtocol>)process {

    if (sessionActive) {
        [postLock lock];
        [processes addObject:process];
        if (processes.count == 1) {
            currentProcess = processes[0];
            [self doPost];
        }
        [postLock unlock];
    }

}

- (void)sessionFailed:(NSString*)error {
    
    [currentProcess.errorDelegate sessionError:error];
    [currentProcess sessionComplete:nil];
    
}

- (void)sessionResponseComplete:(NSDictionary*)sessionResponse {
    
    NSString *error = [sessionResponse objectForKey:@"error"];         // Session request error.
    if (error != nil) {
        [currentProcess.errorDelegate sessionError:error];
        [currentProcess sessionComplete:nil];
    }
    else {
        [currentProcess sessionComplete:sessionResponse];
    }
    
}

- (void)startSession:(id<RequestProcessProtocol>)process {

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
                    NSString *message = responseJson[@"message"];
                    if (message != nil) {
                        [self sessionFailed:message];
                    }
                    else {
                        [self sessionResponseComplete:responseJson];
                    }
                }
            }
        };

    sessionActive = YES;
    currentProcess = process;
    // Perform the session request. The task defaults to "GET" method.
    NSURL *sessionURL = [NSURL URLWithString:[_urlBase stringByAppendingString:sessionPath]];
    NSURLSessionDataTask *sessionTask = [urlSession dataTaskWithURL:sessionURL
                                                  completionHandler:sessionCompletion];
    [sessionTask resume];

}

// Notifications

- (void)sessionEnded:(NSNotification*)notification {
    sessionActive = NO;
}

@end
