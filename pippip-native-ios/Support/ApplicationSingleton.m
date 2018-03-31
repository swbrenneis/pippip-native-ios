//
//  ApplicationSingleton.m
//  pippip-native-ios
//
//  Created by Steve Brenneis on 2/18/18.
//  Copyright © 2018 seComm. All rights reserved.
//

#import "ApplicationSingleton.h"
#import "pippip_native_ios-Swift.h"

static ApplicationSingleton *theInstance = nil;

@implementation ApplicationSingleton

+ (void)bootstrap {

    theInstance = [[ApplicationSingleton alloc] init];
    // Order is important!
    theInstance.accountManager = [[AccountManager alloc] init];
    theInstance.restSession = [[RESTSession alloc] init];
    theInstance.contactDatabase = [[ContactDatabase alloc] init];
    theInstance.conversationCache = [[ConversationCache alloc] init];
    theInstance.config = [[Configurator alloc] init];
    theInstance.accountSession = [[AccountSession alloc] init];
    theInstance.accountSession.restSession = theInstance.restSession;
    theInstance.accountSession.conversationCache = theInstance.conversationCache;
    theInstance.accountSession.sessionState = [[SessionState alloc] init];

}

+ (ApplicationSingleton*)instance {

    return theInstance;

}

@end
