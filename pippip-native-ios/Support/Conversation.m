//
//  Conversation.m
//  pippip-native-ios
//
//  Created by Steve Brenneis on 2/15/18.
//  Copyright © 2018 seComm. All rights reserved.
//

#import "Conversation.h"
#import "ConversationDelegate.h"

@interface Conversation ()
{
    ConversationDelegate *theDelegate;
}

@end

@implementation Conversation

- (instancetype)init {
    self = [super init];

    theDelegate = [[ConversationDelegate alloc] init];
    _delegate = theDelegate;

    return self;
    
}

- (instancetype)initWithMessages:(NSArray *)messages {
    self = [super init];
    
    theDelegate = [[ConversationDelegate alloc] initWithMessages:messages];
    _delegate = theDelegate;
    
    return self;
    
}

- (NSArray*)allMessages {
    return [theDelegate allMessages];
}

- (NSUInteger)count {
    return theDelegate.count;
}

- (NSDictionary*)getIndexedMessage:(NSUInteger)index {
    return [theDelegate getIndexedMessage:index];
}

- (NSInteger)messageExists:(NSDictionary *)triplet {
    return [theDelegate messageExists:triplet];
}
/*
- (NSArray*)pendingMessages {
    return [theDelegate pendingMessages];
}
*/
@end
