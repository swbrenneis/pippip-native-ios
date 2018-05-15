//
//  RESTSession.h
//  pippip-native-ios
//
//  Created by Steve Brenneis on 10/10/17.
//  Copyright © 2017 seComm. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol RequestProcessProtocol;

@interface RESTSession : NSObject <NSURLConnectionDelegate>

@property (nonatomic) NSString *urlBase;

- (void)queuePost:(id<RequestProcessProtocol>)process;

- (void)startSession:(id<RequestProcessProtocol>)process;

@end
