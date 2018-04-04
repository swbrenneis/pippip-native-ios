//
//  ConversationCache.m
//  pippip-native-ios
//
//  Created by Steve Brenneis on 2/20/18.
//  Copyright © 2018 seComm. All rights reserved.
//

#import "ConversationCache.h"
#import "pippip_native_ios-Swift.h"
#import "MessagesDatabase.h"
#import "ContactManager.h"
#import "MutableConversation.h"
#import "DatabaseMessage.h"
#import "ApplicationSingleton.h"
#import <Realm/Realm.h>

@interface ConversationCache ()
{
    NSMutableDictionary<NSString*, MutableConversation*> *conversations;
    MessagesDatabase *messageDatabase;
    ContactManager *contactManager;
}

@property (weak, nonatomic) SessionState *sessionState;

@end;

@implementation ConversationCache

- (instancetype)init {
    self = [super init];

    conversations = [NSMutableDictionary dictionary];
    messageDatabase = [[MessagesDatabase alloc] init];
    contactManager = [[ContactManager alloc] init];

    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(newSession:) name:@"NewSession" object:nil];
    
    return self;

}

- (void)acknowledgeMessage:(NSDictionary *)message {

    MutableConversation *conversation = [self getMutableConversation:message[@"publicId"]];
    NSInteger messageId = [message[@"messageId"] integerValue];
    [conversation acknowledgeMessage:messageId];
    [messageDatabase acknowledgeMessage:messageId];

}

// Marries the cached message to its ID.
- (void)addMessage:(NSMutableDictionary*)message {

    MutableConversation *conversation = [self getMutableConversation:message[@"publicId"]];
    NSInteger messageId = [messageDatabase addMessage:message];
    message[@"messageId"] = [NSNumber numberWithInteger:messageId];
    [conversation addMessage:message];

}

// Marries the cached message to its ID.
- (void)addNewMessages:(NSArray*)messages {

    NSDictionary *first = [messages firstObject];
    NSString *publicId = first[@"fromId"];
    for (NSDictionary *msg in messages) {
        NSMutableDictionary *message = [msg mutableCopy];
        message[@"publicId"] = publicId;
        message[@"cleartext"] = [messageDatabase decryptMessage:message];
        message[@"sent"] = @NO;
        [self addMessage:message];
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
                                              return NSOrderedAscending;
                                          }
                                          else {
                                              return NSOrderedDescending;
                                          }
                                      }];
        [messageList insertObject:message atIndex:index];
    }
    
}

- (void)deleteAllMessages:(NSString *)publicId {

    MutableConversation *conversation = [self getMutableConversation:publicId];
    [conversation deleteAllMessages];
    [messageDatabase deleteAllMessages:publicId];

}

- (void)deleteMessage:(NSInteger)messageId withPublicId:(NSString *)publicId {

    [messageDatabase deleteMessage:messageId];
    MutableConversation *conversation = [self getMutableConversation:publicId];
    [conversation deleteMessage:messageId];

}

- (Conversation*)getConversation:(NSString *)publicId {

    return [self getMutableConversation:publicId];

}

- (NSArray*)getLatestMessageIds:(NSInteger)count withPublicId:(NSString*)publicId {

    Conversation *conversation = [self getConversation:publicId];
    return [conversation latestMessageIds:count];

}

- (MutableConversation*)getMutableConversation:(NSString*)publicId {
    
    MutableConversation *conversation = conversations[publicId];
    if (conversation == nil) {
        conversation = [[MutableConversation alloc] initWithPublicId:publicId];
        conversations[publicId] = conversation;
    }
    return conversation;

}

- (void)markMessageRead:(NSDictionary*)message {

    BOOL read = [message[@"read"] boolValue];
    if (!read) {
        MutableConversation *conversation = [self getMutableConversation:message[@"publicId"]];
        NSInteger messageId = [message[@"messageId"] integerValue];
        [conversation markMessageRead:messageId];
        [messageDatabase markMessageRead:messageId];
        Contact *contact = [contactManager getContact:message[@"publicId"]];
        contact.timestamp = [[NSDate date] timeIntervalSince1970];
        NSMutableArray *contacts = [NSMutableArray array];
        [contacts addObject:contact];
        [contactManager updateContacts:contacts];
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
/*
- (NSArray*)unreadMessageIds:(NSString *)publicId {

    return [messageDatabase unreadMessageIds:publicId];

}
*/
@end
