//
//  ApplicationSingleton.m
//  pippip-native-ios
//
//  Created by Steve Brenneis on 2/18/18.
//  Copyright © 2018 seComm. All rights reserved.
//

#import "pippip_native_ios-Swift.h"
#import "ApplicationSingleton.h"

static ApplicationSingleton *theInstance = nil;

@implementation ApplicationSingleton

+ (void)bootstrap {

    theInstance = [[ApplicationSingleton alloc] init];
    // Order is important!
    theInstance.restSession = [[RESTSession alloc] init];
    theInstance.accountSession = [[AccountSession alloc] init];

}

+ (ApplicationSingleton*)instance {

    return theInstance;

}

@end
