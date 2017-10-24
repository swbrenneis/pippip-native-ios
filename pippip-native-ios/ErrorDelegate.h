//
//  ErrorDelegate.h
//  pippip-native-ios
//
//  Created by Steve Brenneis on 10/20/17.
//  Copyright © 2017 seComm. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ErrorDelegate <NSObject>

- (void)getMethodError:(NSString*)error;

- (void)postMethodError:(NSString*)error;

- (void)responseError:(NSString*)error;

- (void)sessionError:(NSString*)error;

@end
