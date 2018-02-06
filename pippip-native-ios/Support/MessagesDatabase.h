//
//  MessagesDatabase.h
//  pippip-native-ios
//
//  Created by Steve Brenneis on 1/29/18.
//  Copyright © 2018 seComm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SessionState.h"
#import "DatabaseMessage.h"

@interface MessagesDatabase : NSObject

- (void)addMessage:(DatabaseMessage*)message;

- (NSArray*)buildConversation:(NSString*)publicId;

- (NSArray*)mostRecent;

- (BOOL)loadMessages:(SessionState*)state;

@end
