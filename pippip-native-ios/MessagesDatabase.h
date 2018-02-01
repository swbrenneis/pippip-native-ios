//
//  MessagesDatabase.h
//  pippip-native-ios
//
//  Created by Steve Brenneis on 1/29/18.
//  Copyright © 2018 seComm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SessionState.h"
#import "Message.h"

@interface MessagesDatabase : NSObject

- (void)addMessage:(Message*)message;

- (BOOL)loadMessages:(SessionState*)state;

- (NSInteger)messageCountById:(NSString*)senderId;

@end
