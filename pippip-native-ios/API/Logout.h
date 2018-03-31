//
//  Logout.h
//  pippip-native-ios
//
//  Created by Steve Brenneis on 12/10/17.
//  Copyright © 2017 seComm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PostPacket.h"

@class SessionState;

@interface Logout : NSObject<PostPacket>

- (instancetype)initWithState:(SessionState*)state;

@end
