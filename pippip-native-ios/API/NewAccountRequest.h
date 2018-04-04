//
//  NewAccountRequest.h
//  pippip-native-ios
//
//  Created by Steve Brenneis on 10/10/17.
//  Copyright © 2017 seComm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PostPacket.h"

@class SessionState;

@interface NewAccountRequest : NSObject <PostPacket>

- (instancetype)initWithState:(SessionState*)state;

@end
