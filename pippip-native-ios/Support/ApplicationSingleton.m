//
//  ApplicationSingleton.m
//  pippip-native-ios
//
//  Created by Steve Brenneis on 2/18/18.
//  Copyright © 2018 seComm. All rights reserved.
//

#import "ApplicationSingleton.h"

static ApplicationSingleton *theInstance = nil;

@implementation ApplicationSingleton

+ (ApplicationSingleton*)instance {

    if (theInstance == nil) {
        theInstance = [[ApplicationSingleton alloc] init];
    }
    return theInstance;

}

- (instancetype)init {
    self = [super init];

    _accountManager = [[AccountManager alloc] init];
    _restSession = [[RESTSession alloc] init];
    _conversationCache = [[ConversationCache alloc] init];
    _config = [[Configurator alloc] init];
    _accountSession = [[AccountSession alloc] init];
    _accountSession.restSession = _restSession;
    _accountSession.conversationCache = _conversationCache;

    return self;

}

@end
