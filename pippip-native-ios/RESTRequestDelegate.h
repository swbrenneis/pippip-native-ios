//
//  RESTDelegate.h
//  pippip-native-ios
//
//  Created by Steve Brenneis on 10/10/17.
//  Copyright © 2017 seComm. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol RESTRequestDelegate <NSObject>

- (void) restError:(NSString*)error;

- (void) restResponse:(NSDictionary*)response;

@end
