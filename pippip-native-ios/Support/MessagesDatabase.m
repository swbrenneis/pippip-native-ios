//
//  MessagesDatabase.m
//  pippip-native-ios
//
//  Created by Steve Brenneis on 1/29/18.
//  Copyright © 2018 seComm. All rights reserved.
//

#import "pippip_native_ios-Swift.h"
#import "MessagesDatabase.h"
#import "DatabaseMessage.h"
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

- (void)addTextMessage:(TextMessage*)textMessage {

    NSInteger messageId = [self messageExists:textMessage];
    if (messageId == NSNotFound) {
        messageId = [config newMessageId];
        RLMRealm *realm = [RLMRealm defaultRealm];
        DatabaseMessage *dbMessage = [textMessage encodeForDatabase];
        dbMessage.messageId = messageId;
        [realm beginWriteTransaction];
        [realm addObject:dbMessage];
        [realm commitWriteTransaction];
    }
    textMessage.messageId = messageId;
    
}

- (void)addTextMessages:(NSArray<TextMessage *>*)messages {
    
    RLMRealm *realm = [RLMRealm defaultRealm];
    for (TextMessage *textMessage in messages) {
        NSInteger messageId = [self messageExists:textMessage];
        if (messageId == NSNotFound) {
            messageId = [config newMessageId];
            DatabaseMessage *dbMessage = [textMessage encodeForDatabase];
            dbMessage.messageId = messageId;
            [realm beginWriteTransaction];
            [realm addObject:dbMessage];
            [realm commitWriteTransaction];
        }
        textMessage.messageId = messageId;
    }
    
}

- (NSArray<TextMessage*>*)allTextMessages {
    
    RLMResults<DatabaseMessage*> *messages = [DatabaseMessage allObjects];
    NSMutableArray<TextMessage*> *textMessages = [NSMutableArray array];
    for (DatabaseMessage *dbMessage in messages) {
        [textMessages addObject:[[TextMessage alloc] initWithDbMessage:dbMessage]];
    }
    return textMessages;
    
}

- (NSArray<NSNumber*>*)allMessageIds {
    
    RLMResults<DatabaseMessage*> *messages = [DatabaseMessage allObjects];
    NSMutableArray *ids = [NSMutableArray array];
    for (DatabaseMessage *dbMessage in messages) {
        [ids addObject:[NSNumber numberWithInteger:dbMessage.messageId]];
    }
    return ids;
    
}

- (void)clearMessages:(NSInteger)contactId {
    
    RLMRealm *realm = [RLMRealm defaultRealm];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"contactId = %ld", contactId];
    RLMResults<DatabaseMessage*> *messages = [DatabaseMessage objectsWithPredicate:predicate];
    [realm beginWriteTransaction];
    for (DatabaseMessage *message in messages) {
        [realm deleteObject:message];
    }
    [realm commitWriteTransaction];

}

- (void)deleteAllMessages {
    
    RLMRealm *realm = [RLMRealm defaultRealm];
    RLMResults<DatabaseMessage*> *messages = [DatabaseMessage allObjects];
    [realm beginWriteTransaction];
    for (DatabaseMessage *message in messages) {
        [realm deleteObject:message];
    }
    [realm commitWriteTransaction];

}

- (void)deleteMessage:(NSInteger)messageId {
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"messageId = %lld", messageId];
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
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"messageId = %lld", messageId];
    RLMResults<DatabaseMessage*> *messages = [DatabaseMessage objectsWithPredicate:predicate];
    if (messages.count > 0) {
        return [[Message alloc] initWithDbMessage:[messages firstObject]];
    }
    else {
        return nil;
    }
    
}

- (NSInteger)getMessageCount:(NSInteger)contactId {
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"contactId = %lld", contactId];
    RLMResults<DatabaseMessage*> *messages = [DatabaseMessage objectsWithPredicate:predicate];
    return messages.count;

}

- (TextMessage*) getTextMessage:(NSInteger)messageId {
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"messageId = %lld", messageId];
    RLMResults<DatabaseMessage*> *messages = [DatabaseMessage objectsWithPredicate:predicate];
    if (messages.count > 0) {
        return [[TextMessage alloc] initWithDbMessage:[messages firstObject]];
    }
    else {
        return nil;
    }
    
}

- (NSArray<TextMessage*>*) getTextMessages:(NSInteger)contactId
                              withPosition:(NSInteger)pos
                                 withCount:(NSInteger)count {

    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"contactId = %lld", contactId];
    RLMResults<DatabaseMessage*> *messages = [[DatabaseMessage objectsWithPredicate:predicate]
                                              sortedResultsUsingKeyPath:@"timestamp" ascending:YES];
    NSMutableArray *textMessages = [NSMutableArray array];
    NSUInteger actual = pos + count;
    if (actual > messages.count) {
        actual = messages.count;
    }
    for (NSUInteger index = pos; index < actual; ++index) {
        [textMessages addObject:[[TextMessage alloc] initWithDbMessage:messages[index]]];
    }
    return textMessages;

}

- (NSInteger)messageExists:(TextMessage*)message {

    NSInteger contactId = message.contactId;
    NSInteger sequence = message.sequence;
    NSInteger timestamp = message.timestamp;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"contactId = %lld && sequence = %lld && timestamp = %lld", contactId, sequence, timestamp];
    RLMResults<DatabaseMessage*> *messages = [DatabaseMessage objectsWithPredicate:predicate];
    if (messages.count > 0) {
        DatabaseMessage *dbMessage = [messages firstObject];
        return dbMessage.messageId;
    }
    else {
        return NSNotFound;
    }

}

- (TextMessage*)mostRecentTextMessage:(NSInteger)contactId {

    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"contactId = %lld", contactId];
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

- (void)scrubCleartext:(TextMessage *)message {

        RLMRealm *realm = [RLMRealm defaultRealm];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"messageId = %lld", message.messageId];
        RLMResults<DatabaseMessage*> *messages = [DatabaseMessage objectsWithPredicate:predicate];
        if (messages.count > 0) {
            DatabaseMessage *dbMessage = [messages firstObject];
            [realm beginWriteTransaction];
            dbMessage.cleartext = nil;
            [realm commitWriteTransaction];
        }
        else {
            NSLog(@"Message with ID %lld not found for update", message.messageId);
        }
    
}

- (void)updateMessage:(Message *)message {
    
    RLMRealm *realm = [RLMRealm defaultRealm];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"messageId = %lld", message.messageId];
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

- (void)updateCleartext:(TextMessage *)message {

    if (config.storeCleartextMessages) {
        RLMRealm *realm = [RLMRealm defaultRealm];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"messageId = %lld", message.messageId];
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
    
}

@end
