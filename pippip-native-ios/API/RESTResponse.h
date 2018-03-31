//
//  RestResponse.h
//  pippip-native-ios
//
//  Created by Steve Brenneis on 10/10/17.
//  Copyright © 2017 seComm. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import "ErrorDelegate.h"

@protocol ErrorDelegate;

@protocol RESTResponse <NSObject>

- (BOOL)processResponse:(NSDictionary*)response errorDelegate:(id<ErrorDelegate>)delegate;

@end
