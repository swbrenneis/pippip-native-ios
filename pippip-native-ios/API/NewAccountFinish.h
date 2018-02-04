//
//  NewAccountFinish.h
//  pippip-native-ios
//
//  Created by Steve Brenneis on 10/25/17.
//  Copyright © 2017 seComm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PostPacket.h"
#import "SessionState.h"

@interface NewAccountFinish : NSObject <PostPacket>

- (instancetype)initWithState:(SessionState*)state;

@end
