//
//  MessagesDatabase.m
//  pippip-native-ios
//
//  Created by Steve Brenneis on 1/29/18.
//  Copyright © 2018 seComm. All rights reserved.
//

#import "MessagesDatabase.h"
#import <Realm/Realm.h>

@interface MessagesDatabase ()
{

}

@property (weak, nonatomic) SessionState *sessionState;

@end

@implementation MessagesDatabase

- (void)addMessage:(DatabaseMessage*)message {

}

- (NSArray*)mostRecent {

    NSMutableArray *recent = [NSMutableArray array];
    NSMutableDictionary *sample = [NSMutableDictionary dictionary];
    sample[@"read"] = @NO;
    sample[@"sender"] = @"Sally Joe";
    sample[@"message"] = @"The quick brown fox jumped over the lazy dog";
    sample[@"dateTime"] = @"Friday 14:53";
    [recent addObject:sample];

    return recent;

}

- (BOOL)loadMessages:(SessionState*)state {

    _sessionState = state;
    return YES;
    
}

@end
