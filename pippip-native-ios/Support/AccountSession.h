//
//  AccountSession.h
//  pippip-native-ios
//
//  Created by Steve Brenneis on 1/25/18.
//  Copyright © 2018 seComm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SessionState.h"
#import "ContactManager.h"
#import "MessageManager.h"
#import "RequestProcess.h"
#import "RESTSession.h"

@interface AccountSession : NSObject <RequestProcess>

@property (nonatomic) SessionState *sessionState;
@property (nonatomic) ContactManager *contactManager;
@property (nonatomic) MessageManager *messageManager;

-(instancetype)initWithRESTSession:(RESTSession*)restSession;

- (void)startSession:(SessionState*)state withConfig:(NSDictionary*)config;

- (void)endSession;

@end
