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

- (instancetype)initWithPublicId:(NSString *)publicId {
    self = [super init];

    theDelegate = [[ConversationDelegate alloc] initWithPublicId:publicId];
    _delegate = theDelegate;

    return self;
    
}
/*
- (instancetype)initWithMessageIds:(NSArray *)messages {
    self = [super init];
    
    theDelegate = [[ConversationDelegate alloc] initWithMessageIds:messages];
    _delegate = theDelegate;
    
    return self;
    
}
*/
- (NSArray*)allMessageIds {
    return [theDelegate allMessageIds];
}

- (NSUInteger)count {
    return theDelegate.count;
}

- (NSMutableDictionary*)getMessage:(NSUInteger)messageId {
    return [theDelegate getMessage:messageId];
}

@end
