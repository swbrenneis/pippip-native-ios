//
//  EnclaveResponse.h
//  pippip-native-ios
//
//  Created by Steve Brenneis on 12/13/17.
//  Copyright © 2017 seComm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RESTResponse.h"
#import "SessionState.h"

@interface EnclaveResponse : NSObject<RESTResponse>

- (instancetype) initWithState:(SessionState*)state;

- (NSDictionary*) getResponse;

@end
