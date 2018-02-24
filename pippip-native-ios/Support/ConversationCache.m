//
//  ConversationCache.m
//  pippip-native-ios
//
//  Created by Steve Brenneis on 2/20/18.
//  Copyright © 2018 seComm. All rights reserved.
//

#import "ConversationCache.h"
#import "MessagesDatabase.h"
#import "ContactDatabase.h"
#import "MutableConversation.h"
#import "DatabaseMessage.h"
#import "ApplicationSingleton.h"
#import <Realm/Realm.h>

@interface ConversationCache ()
{
    NSMutableDictionary<NSString*, MutableConversation*> *conversations;
    MessagesDatabase *messageDatabase;
}

@property (weak, nonatomic) SessionState *sessionState;

@end;

@implementation ConversationCache

- (instancetype)init {
    self = [super init];

    conversations = [NSMutableDictionary dictionary];
    messageDatabase = [[MessagesDatabase alloc] init];

    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(newSession:) name:@"NewSession" object:nil];
    
    return self;

}

- (void)acknowledgeMessage:(NSDictionary *)message {

    MutableConversation *conversation = [self getMutableConversation:message[@"publicId"]];
    NSInteger messageId = [conversation messageExists:message];
    if (messageId != NSNotFound) {
        [conversation acknowledgeMessage:message];
        [messageDatabase acknowledgeMessage:messageId];
    }
    else {
        NSLog(@"ConversationCache.acknowledgeMessage - Message not found in conversation");
    }

}

// Filters duplicates, marries the cached message to its ID.
- (void)addMessage:(NSMutableDictionary*)message {

    MutableConversation *conversation = [self getMutableConversation:message[@"publicId"]];
    NSInteger messageId = [conversation messageExists:message];
    if (messageId == NSNotFound) {
        messageId = [messageDatabase addMessage:message];
        message[@"messageId"] = [NSNumber numberWithInteger:messageId];
        [conversation addMessage:message];
    }

}

// Filters duplicates, marries the cached message to its ID.
- (void)addMessages:(NSArray*)messages {

    NSDictionary *first = [messages firstObject];
    NSString *publicId = first[@"fromId"];
    MutableConversation *conversation = [self getMutableConversation:publicId];
    for (NSDictionary *msg in messages) {
        NSMutableDictionary *message = [msg mutableCopy];
        message[@"publicId"] = publicId;
        NSInteger messageId = [conversation messageExists:message];
        if (messageId == NSNotFound) {
            messageId = [messageDatabase addMessage:message];
            message[@"cleartext"] = [messageDatabase decryptMessage:message];
            message[@"sent"] = @NO;
            message[@"messageId"] = [NSNumber numberWithInteger:messageId];
            [conversation addMessage:message];
        }
    }

}

- (void)addMessageSorted:(NSDictionary*)message withMessageList:(NSMutableArray*)messageList {
    
    if (messageList.count == 0) {
        [messageList addObject:message];
    }
    else {
        // Add the message in sorted order.
        NSUInteger index = [messageList indexOfObject:message
                                        inSortedRange:(NSRange){0, messageList.count}
                                              options:NSBinarySearchingInsertionIndex
                                      usingComparator:^(id obj1, id obj2) {
                                          NSDictionary *msg1 = obj1;
                                          NSNumber *ts1 = msg1[@"timestamp"];
                                          NSInteger time1 = [ts1 integerValue];
                                          NSDictionary *msg2 = obj2;
                                          NSNumber *ts2 = msg2[@"timestamp"];
                                          NSInteger time2 = [ts2 integerValue];
                                          if (time1 == time2) {
                                              // Hope not!
                                              NSLog(@"%@", @"Equal message timestamps!");
                                              return NSOrderedSame;
                                          }
                                          else if (time1 > time2) {
                                              return NSOrderedDescending;
                                          }
                                          else {
                                              return NSOrderedAscending;
                                          }
                                      }];
        [messageList insertObject:message atIndex:index];
    }
    
}

- (void)deleteAllMessages:(NSString *)publicId {

    [conversations removeObjectForKey:publicId];
    [messageDatabase deleteAllMessages:publicId];

}

- (Conversation*)getConversation:(NSString *)publicId {

    return [self getMutableConversation:publicId];

}

- (MutableConversation*)getMutableConversation:(NSString*)publicId {
    
    MutableConversation *conversation = conversations[publicId];
    if (conversation == nil) {  // Not in the cache, get it from the database
        // This might return an empty array.
        NSArray *messages = [messageDatabase loadConversation:publicId];
        conversation = [[MutableConversation alloc] initWithMessages:messages];
        conversations[publicId] = conversation;
    }
    return conversation;

}

- (void)markMessagesRead:(NSString *)publicId {

    MutableConversation *conversation = [self getMutableConversation:publicId];
    NSArray *messages = [conversation allMessages];
    for (NSMutableDictionary *message in messages) {
        if (![message[@"read"] boolValue]) {
            NSInteger messageId = [conversation markMessageRead:message];
            if (messageId != NSNotFound) {
                [messageDatabase markMessageRead:messageId];
            }
        }
    }

}

- (NSArray*)mostRecentMessages {

    NSMutableArray *messages = [NSMutableArray array];
    Configurator *config = [ApplicationSingleton instance].config;
    NSArray *ids = [config allContactIds];
    for (NSNumber *cid in ids) {
        NSDictionary *message = [messageDatabase mostRecentMessage:[cid integerValue]];
        if (message != nil) {
            [self addMessageSorted:message withMessageList:messages];
        }
    }
    return messages;

}

- (void)newSession:(NSNotification*)notification {

    _sessionState = (SessionState*)notification.object;
    [conversations removeAllObjects];

}

@end
