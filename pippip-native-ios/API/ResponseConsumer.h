//
//  ResponseConsumer.h
//  pippip-native-ios
//
//  Created by Steve Brenneis on 12/18/17.
//  Copyright © 2017 seComm. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ErrorDelegate;

@protocol ResponseConsumer <NSObject>

@property (nonatomic) id<ErrorDelegate> errorDelegate;

- (void)response:(NSDictionary*)info;

@end

