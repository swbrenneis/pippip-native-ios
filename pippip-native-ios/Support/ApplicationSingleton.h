//
//  ApplicationSingleton.h
//  pippip-native-ios
//
//  Created by Steve Brenneis on 2/18/18.
//  Copyright © 2018 seComm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AccountManager.h"
#import "AccountSession.h"
#import "RESTSession.h"
#import "ConversationCache.h"
#import "Configurator.h"
#import "ContactDatabase.h"

@interface ApplicationSingleton : NSObject

+ (void)bootstrap;

+ (ApplicationSingleton*)instance;

@property (strong, nonatomic) AccountManager *accountManager;
@property (strong, nonatomic) AccountSession *accountSession;
@property (strong, nonatomic) RESTSession *restSession;
@property (strong, nonatomic) ConversationCache *conversationCache;
@property (strong, nonatomic) Configurator *config;
@property (strong, nonatomic) ContactDatabase *contactDatabase;

@end
