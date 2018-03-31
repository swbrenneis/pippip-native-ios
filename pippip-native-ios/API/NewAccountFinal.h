//
//  NewAccountFinal.h
//  pippip-native-ios
//
//  Created by Steve Brenneis on 10/25/17.
//  Copyright © 2017 seComm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RESTResponse.h"

@class SessionState;

@interface NewAccountFinal : NSObject <RESTResponse>

- (instancetype)initWithState:(SessionState*)state;

@end
