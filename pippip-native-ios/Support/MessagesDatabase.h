//
//  MessagesDatabase.h
//  pippip-native-ios
//
//  Created by Steve Brenneis on 1/29/18.
//  Copyright © 2018 seComm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SessionState.h"

@interface MessagesDatabase : NSObject

@property (nonatomic) NSMutableDictionary *conversations;

- (instancetype)initWithSessionState:(SessionState*)state;

- (void)addNewMessage:(NSMutableDictionary*)message;

- (NSArray*)loadConversations;

@end
