//
//  ResponseConsumer.h
//  pippip-native-ios
//
//  Created by Steve Brenneis on 12/18/17.
//  Copyright © 2017 seComm. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ResponseConsumer <NSObject>

- (void)response:(NSDictionary*)info;

@end

