//
//  MessagesDatabase.m
//  pippip-native-ios
//
//  Created by Steve Brenneis on 1/29/18.
//  Copyright © 2018 seComm. All rights reserved.
//

#import "pippip_native_ios-Swift.h"
#import "MessagesDatabase.h"
#import "ApplicationSingleton.h"
#import "DatabaseMessage.h"
#import "Configurator.h"
#import "CKIVGenerator.h"
#import "CKGCMCodec.h"
#import <Realm/Realm.h>

@interface MessagesDatabase ()
{
    ContactManager *contactManager;
    Configurator *config;
}

@property (weak, nonatomic) SessionState *sessionState;

@end

@implementation MessagesDatabase

- (instancetype)init {
    self = [super init];

    contactManager = [[ContactManager alloc] init];
    config = [[Configurator alloc] init];

    return self;

}

- (NSArray<NSNumber*>*)allMessageIds {

    RLMResults<DatabaseMessage*> *messages = [DatabaseMessage allObjects];
    NSMutableArray *ids = [NSMutableArray array];
    for (DatabaseMessage *dbMessage in messages) {
        [ids addObject:[NSNumber numberWithInteger:dbMessage.messageId]];
    }
    return ids;

}

- (void)addTextMessage:(TextMessage*)textMessage {
    
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];
    [realm addObject:[textMessage encodeForDatabase]];
    [realm commitWriteTransaction];
    
}

- (void)addTextMessages:(NSArray<TextMessage *>*)messages {
    
    RLMRealm *realm = [RLMRealm defaultRealm];
    for (TextMessage *message in messages) {
        message.acknowledged = NO;
        [realm beginWriteTransaction];
        [realm addObject:[message encodeForDatabase]];
        [realm commitWriteTransaction];
    }
    
}

- (void)deleteAllMessages:(NSInteger)contactId {
    
    RLMRealm *realm = [RLMRealm defaultRealm];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"contactId = %ld", contactId];
    RLMResults<DatabaseMessage*> *messages = [DatabaseMessage objectsWithPredicate:predicate];
    for (DatabaseMessage *message in messages) {
        [realm beginWriteTransaction];
        [realm deleteObject:message];
        [realm commitWriteTransaction];
    }
    
}

- (void)deleteAllMessages {
    
    RLMRealm *realm = [RLMRealm defaultRealm];
    RLMResults<DatabaseMessage*> *messages = [DatabaseMessage allObjects];
    for (DatabaseMessage *message in messages) {
        [realm beginWriteTransaction];
        [realm deleteObject:message];
        [realm commitWriteTransaction];
    }
    
}

- (void)deleteMessage:(NSInteger)messageId {
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"messageId = %ld", messageId];
    RLMResults<DatabaseMessage*> *messages = [DatabaseMessage objectsWithPredicate:predicate];
    if (messages.count > 0) {
        RLMRealm *realm = [RLMRealm defaultRealm];
        [realm beginWriteTransaction];
        [realm deleteObject:[messages firstObject]];
        [realm commitWriteTransaction];
    }
    else {
        NSLog(@"MessagesDatabase.deleteMessage Message with ID %ld not found", messageId);
    }
    
}

- (Message*) getMessage:(NSInteger)messageId {
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"messageId = %ld", messageId];
    RLMResults<DatabaseMessage*> *messages = [DatabaseMessage objectsWithPredicate:predicate];
    if (messages.count > 0) {
        return [[Message alloc] initWithDbMessage:[messages firstObject]];
    }
    else {
        return nil;
    }
    
}

- (TextMessage*) getTextMessage:(NSInteger)messageId {
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"messageId = %ld", messageId];
    RLMResults<DatabaseMessage*> *messages = [DatabaseMessage objectsWithPredicate:predicate];
    if (messages.count > 0) {
        return [[TextMessage alloc] initWithDbMessage:[messages firstObject]];
    }
    else {
        return nil;
    }
    
}

- (NSArray<TextMessage*>*) getTextMessages:(NSInteger)messageId {
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"messageId = %ld", messageId];
    RLMResults<DatabaseMessage*> *messages = [DatabaseMessage objectsWithPredicate:predicate];
    NSMutableArray *textMessages = [NSMutableArray array];
    for (DatabaseMessage *dbMessage in messages) {
        [textMessages addObject:[[TextMessage alloc] initWithDbMessage:dbMessage]];
    }
    return textMessages;
    
}

- (TextMessage*)mostRecentTextMessage:(NSInteger)contactId {
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"contactId = %ld", contactId];
    RLMResults<DatabaseMessage*> *messages = [[DatabaseMessage objectsWithPredicate:predicate]
                                              sortedResultsUsingKeyPath:@"timestamp" ascending:NO];
    if (messages.count > 0) {
        return [[TextMessage alloc] initWithDbMessage:[messages firstObject]];
    }
    else {
        NSLog(@"No messages found for contact %ld", contactId);
        return nil;
    }
    
}

- (void)updateMessage:(Message *)message {
    
    RLMRealm *realm = [RLMRealm defaultRealm];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"messageId = %ld", message.messageId];
    RLMResults<DatabaseMessage*> *messages = [DatabaseMessage objectsWithPredicate:predicate];
    if (messages.count > 0) {
        DatabaseMessage *dbMessage = [messages firstObject];
        [realm beginWriteTransaction];
        dbMessage.acknowledged = message.acknowledged;
        dbMessage.read = message.read;
        dbMessage.timestamp = message.timestamp;
        [realm commitWriteTransaction];
    }
    else {
        NSLog(@"Message with ID %lld not found for update", message.messageId);
    }
    
}

- (void)updateTextMessage:(TextMessage *)message {
    
    RLMRealm *realm = [RLMRealm defaultRealm];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"messageId = %ld", message.messageId];
    RLMResults<DatabaseMessage*> *messages = [DatabaseMessage objectsWithPredicate:predicate];
    if (messages.count > 0) {
        DatabaseMessage *dbMessage = [messages firstObject];
        [realm beginWriteTransaction];
        dbMessage.cleartext = message.cleartext;
        [realm commitWriteTransaction];
    }
    else {
        NSLog(@"Message with ID %lld not found for update", message.messageId);
    }
    
}

@end
