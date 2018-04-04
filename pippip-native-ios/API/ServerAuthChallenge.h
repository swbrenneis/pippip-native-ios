//
//  ServerAuthChallenge.h
//  pippip-native-ios
//
//  Created by Steve Brenneis on 12/4/17.
//  Copyright © 2017 seComm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RESTResponse.h"

@class SessionState;

@interface ServerAuthChallenge : NSObject<RESTResponse>

- (instancetype)initWithState:(SessionState*)state;

@end
