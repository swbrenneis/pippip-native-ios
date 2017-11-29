//
//  NewAccountResponse.h
//  pippip-native-ios
//
//  Created by Steve Brenneis on 10/10/17.
//  Copyright © 2017 seComm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RESTResponse.h"
#import "SessionState.h"

@interface NewAccountResponse : NSObject <RESTResponse>

- (instancetype) initWithState:(SessionState*)state;

@end
