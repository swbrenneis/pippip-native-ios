//
//  RESTSession.h
//  pippip-native-ios
//
//  Created by Steve Brenneis on 10/10/17.
//  Copyright © 2017 seComm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RequestProcess.h"

@protocol RequestStep;

@interface RESTSession : NSObject <NSURLConnectionDelegate>

- (void)doPost;

- (void)startSession;

@property (nonatomic) id<RequestProcess> requestProcess;

@end
