//
//  AuthenticationResponse.h
//  pippip-native-ios
//
//  Created by Steve Brenneis on 12/4/17.
//  Copyright © 2017 seComm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SessionState.h"
#import "RESTResponse.h"

@interface AuthenticationResponse : NSObject<RESTResponse>

- (instancetype) initWithState:(SessionState*)state;

@end
