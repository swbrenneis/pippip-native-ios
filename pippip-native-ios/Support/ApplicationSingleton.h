//
//  ApplicationSingleton.h
//  pippip-native-ios
//
//  Created by Steve Brenneis on 2/18/18.
//  Copyright © 2018 seComm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AccountSession.h"
#import "RESTSession.h"

@interface ApplicationSingleton : NSObject

+ (void)bootstrap;

+ (ApplicationSingleton*)instance;

@property (strong, nonatomic) AccountSession *accountSession;
@property (strong, nonatomic) RESTSession *restSession;

@end
