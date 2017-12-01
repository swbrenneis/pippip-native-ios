//
//  AuthenticationRequest.h
//  pippip-native-ios
//
//  Created by Steve Brenneis on 12/1/17.
//  Copyright © 2017 seComm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PostPacket.h"
#import "SessionState.h"

@interface AuthenticationRequest : NSObject <PostPacket>

- (instancetype)initWithState:(SessionState*)state;

@end
