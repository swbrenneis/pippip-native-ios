//
//  EnclaveRequest.h
//  pippip-native-ios
//
//  Created by Steve Brenneis on 12/13/17.
//  Copyright © 2017 seComm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PostPacket.h"
#import "SessionState.h"

@interface EnclaveRequest : NSObject<PostPacket>

- (void)setRequest:(NSDictionary*)request;

@end
