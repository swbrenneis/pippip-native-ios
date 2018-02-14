//
//  MessagesDatabase.m
//  pippip-native-ios
//
//  Created by Steve Brenneis on 1/29/18.
//  Copyright © 2018 seComm. All rights reserved.
//

#import <Realm/Realm.h>
#import "MessagesDatabase.h"
#import "DatabaseMessage.h"
#import "ContactDatabase.h"
#import "Configurator.h"
#import "CKIVGenerator.h"
#import "CKGCMCodec.h"

@interface MessagesDatabase ()
{
    NSInteger messageId;
    ContactDatabase *contacts;
    Configurator *config;
    NSMutableDictionary *conversations;
}

@property (weak, nonatomic) SessionState *sessionState;

@end

@implementation MessagesDatabase

- (instancetype)initWithSessionState:(SessionState *)state {
    self = [super init];

    _sessionState = state;
    conversations = [NSMutableDictionary dictionary];
    contacts = [[ContactDatabase alloc] initWithSessionState:state];
    config = [[Configurator alloc] initWithSessionState:state];

    return self;

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

- (void)addMessageToConversation:(NSMutableDictionary*)message {

    NSString *publicId = message[@"publicId"];
    NSMutableArray *conversation = [self loadConversation:publicId];
    [self addMessageSorted:message withMessageList:conversation];

}

- (void)addNewMessage:(NSMutableDictionary*)message {
    
    NSString *publicId = message[@"publicId"];
    NSNumber *sq = message[@"sequence"];
    NSNumber *ts = message[@"timestamp"];

    if (![self messageExists:publicId withSequence:[sq integerValue] withTimestamp:[ts integerValue]]) {
        [self addMessageToConversation:message];
        
        // Add the message to the database
        DatabaseMessage *dbMessage = [[DatabaseMessage alloc] init];
        dbMessage.messageId = [config newMessageId];
        dbMessage.contactId = [config getContactId:message[@"publicId"]];
        dbMessage.messageType = message[@"messageType"];
        NSNumber *ki = message[@"keyIndex"];
        dbMessage.keyIndex = [ki integerValue];
        dbMessage.sequence = [sq integerValue];
        dbMessage.timestamp = [ts integerValue];
        dbMessage.read = NO;
        NSNumber *ack = message[@"acknowledged"];
        dbMessage.acknowledged = [ack boolValue];
        NSNumber *sent = message[@"sent"];
        dbMessage.sent = [sent boolValue];
        dbMessage.message = [[NSData alloc] initWithBase64EncodedString:message[@"body"] options:0];
        
        RLMRealm *realm = [RLMRealm defaultRealm];
        [realm beginWriteTransaction];
        [realm addObject:dbMessage];
        [realm commitWriteTransaction];
    }

}

- (NSMutableDictionary*)decodeMessage:(DatabaseMessage*)dbMessage withContact:(NSDictionary*)contact {

    NSMutableDictionary *message = [NSMutableDictionary dictionary];
    message[@"publicId"] = contact[@"publicId"];
    NSString *nickname = contact[@"nickname"];
    if (nickname != nil) {
        message[@"nickname"] = nickname;
    }
    message[@"contactId"] = [NSNumber numberWithInteger:dbMessage.contactId];
    message[@"messageType"] = dbMessage.messageType;
    message[@"messageType"] = [NSNumber numberWithInteger:dbMessage.timestamp];
    message[@"read"] = [NSNumber numberWithBool:dbMessage.read];
    message[@"acknowledged"] = [NSNumber numberWithBool:dbMessage.acknowledged];
    message[@"timestamp"] = [NSNumber numberWithInteger:dbMessage.timestamp];
    message[@"sequence"] = [NSNumber numberWithInteger:dbMessage.sequence];
    message[@"sent"] = [NSNumber numberWithBool:dbMessage.sent];
    message[@"cleartext"] = [self decryptMessage:dbMessage withContact:contact];
    return message;

}

- (NSString*)decryptMessage:(DatabaseMessage*)message withContact:(NSDictionary*)contact {

    CKIVGenerator *ivGen = [[CKIVGenerator alloc] init];
    NSData *iv = [ivGen generate:message.sequence withNonce:contact[@"nonce"]];
    CKGCMCodec *codec = [[CKGCMCodec alloc] initWithData:message.message];
    [codec setIV:iv];
    NSArray *messageKeys = contact[@"messageKeys"];
    NSError *error = nil;
    [codec decrypt:messageKeys[message.keyIndex] withAuthData:contact[@"authData"] withError:&error];
    return [codec getString];

}

// Debug only!!!
- (void)deleteAllMessages {

    RLMRealm *realm = [RLMRealm defaultRealm];
    RLMResults<DatabaseMessage*> *messages = [DatabaseMessage allObjects];
    for (DatabaseMessage *message in messages) {
        [realm beginWriteTransaction];
        [realm deleteObject:message];
        [realm commitWriteTransaction];
    }

}

- (NSArray*)getConversation:(NSString *)publicId {

    NSArray *conversation = conversations[publicId];
    if (conversation == nil) {
        conversation = [self loadConversation:publicId];
    }
    return conversation;

}

- (NSMutableArray*)loadConversation:(NSString*)publicId {

    NSMutableArray* conversation = [NSMutableArray array];
    NSInteger contactId = [config getContactId:publicId];
    NSDictionary *contact = [contacts getContact:publicId];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"contactId = %ld", contactId];
    RLMResults<DatabaseMessage*> *messages = [[DatabaseMessage objectsWithPredicate:predicate]
                                              sortedResultsUsingKeyPath:@"timestamp" ascending:YES];
    for (DatabaseMessage *dbMessage in messages) {
        NSMutableDictionary *message = [self decodeMessage:dbMessage withContact:contact];
        [conversation addObject:message];
        //[self addMessageSorted:message withConversation:conversation];
    }
    return conversation;

}

// Is this necessary?
- (NSArray*)loadConversations {

    [conversations removeAllObjects];
    NSMutableArray *pendingMessages = [NSMutableArray array];
    RLMResults<DatabaseMessage*> *messages = [DatabaseMessage allObjects];
    for (DatabaseMessage *dbMessage in messages) {
        NSMutableDictionary *message = [NSMutableDictionary dictionary];
        message[@"contactId"] = [NSNumber numberWithInteger:dbMessage.contactId];
        message[@"messageType"] = dbMessage.messageType;
        message[@"messageType"] = [NSNumber numberWithInteger:dbMessage.timestamp];
        message[@"read"] = [NSNumber numberWithBool:dbMessage.read];
        message[@"acknowledged"] = [NSNumber numberWithBool:dbMessage.acknowledged];
        message[@"timestamp"] = [NSNumber numberWithInteger:dbMessage.timestamp];
        message[@"sequence"] = [NSNumber numberWithInteger:dbMessage.sequence];
        message[@"sent"] = [NSNumber numberWithBool:dbMessage.sent];

        NSDictionary *contact = [contacts getContactById:dbMessage.contactId];
        message[@"publicId"] = contact[@"publicId"];
        NSString *nickname = contact[@"nickname"];
        if (nickname != nil) {
            message[@"nickname"] = nickname;
        }
        message[@"cleartext"] = [self decryptMessage:dbMessage withContact:contact];
        [self addMessageToConversation:message];
        if (!dbMessage.acknowledged) {
            [pendingMessages addObject:message];
        }
    }
    return pendingMessages;

}

- (BOOL)messageExists:(NSString*)publicId withSequence:(NSInteger)sequence withTimestamp:(NSInteger)timestamp {
    
    NSArray *conversation = [self loadConversation:publicId];
    if (conversation != nil) {
        for (NSDictionary *message in conversation) {
            NSNumber *sq = message[@"sequence"];
            NSNumber *ts = message[@"timestamp"];
            if ([sq integerValue] == sequence && [ts integerValue] == timestamp) {
                return YES;
            }
        }
    }
    return NO;
    
}

- (NSArray*)mostRecentMessages {

    NSMutableArray *recent = [NSMutableArray array];
    NSArray *contactIds = [config allContactIds];
    for (NSNumber *cid in contactIds) {
        NSInteger contactId = [cid integerValue];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"contactId = %ld", contactId];
        RLMResults<DatabaseMessage*> *messages = [[DatabaseMessage objectsWithPredicate:predicate]
                                                  sortedResultsUsingKeyPath:@"timestamp" ascending:NO];
        if (messages.count > 0) {
            NSDictionary *contact = [contacts getContactById:contactId];
            NSDictionary *message = [self decodeMessage:[messages firstObject] withContact:contact];
            [self addMessageSorted:message withMessageList:recent];
        }
    }
    return recent;

}

@end
