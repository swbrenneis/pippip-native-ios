//
//  NewAccountResponse.h
//  pippip-native-ios
//
//  Created by Steve Brenneis on 10/10/17.
//  Copyright © 2017 seComm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RESTRequestDelegate.h"
#import "RESTResponseDelegate.h"
#import "SessionState.h"

@interface NewAccountResponse : NSObject <RESTRequestDelegate>

- (instancetype)initWithState:(SessionState*)state responseDelegate:(id<RESTResponseDelegate>)delegate;

@end
