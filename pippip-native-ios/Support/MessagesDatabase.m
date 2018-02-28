//
//  MessagesDatabase.m
//  pippip-native-ios
//
//  Created by Steve Brenneis on 1/29/18.
//  Copyright © 2018 seComm. All rights reserved.
//

#import <Realm/Realm.h>
#import "MessagesDatabase.h"
#import "ApplicationSingleton.h"
#import "DatabaseMessage.h"
#import "ContactDatabase.h"
#import "Configurator.h"
#import "CKIVGenerator.h"
#import "CKGCMCodec.h"

@interface MessagesDatabase ()
{
    NSInteger messageId;
    ContactDatabase *contactDatabase;
}

@property (weak, nonatomic) SessionState *sessionState;

@end

@implementation MessagesDatabase

- (instancetype)init {
    self = [super init];

    contactDatabase = [[ContactDatabase alloc] init];

    return self;

}

- (void)acknowledgeMessage:(NSInteger)messageId {

    RLMRealm *realm = [RLMRealm defaultRealm];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"messageId = %ld", messageId];
    RLMResults<DatabaseMessage*> *messages = [DatabaseMessage objectsWithPredicate:predicate];
    if (messages.count > 0) {
        DatabaseMessage *dbMessage = [messages firstObject];
        [realm beginWriteTransaction];
        dbMessage.acknowledged = YES;
        [realm commitWriteTransaction];
    }
    else {
        NSLog(@"MessagesDatabase.acknowledgeMessage - Message not found in database");
    }

}

- (NSInteger)addMessage:(NSDictionary*)message {
    
    // Add the message to the database
    DatabaseMessage *dbMessage = [[DatabaseMessage alloc] init];
    Configurator *config = [ApplicationSingleton instance].config;
    NSInteger messageId = [config newMessageId];
    dbMessage.messageId = messageId;
    dbMessage.contactId = [config getContactId:message[@"publicId"]];
    dbMessage.messageType = message[@"messageType"];
    dbMessage.keyIndex = [message[@"keyIndex"] integerValue];
    dbMessage.sequence = [message[@"sequence"] integerValue];
    dbMessage.timestamp = [message[@"timestamp"] integerValue];
    dbMessage.read = [message[@"read"] boolValue];
    dbMessage.acknowledged = [message[@"acknowledged"] boolValue];
    dbMessage.sent = [message[@"sent"] boolValue];
    dbMessage.message = [[NSData alloc] initWithBase64EncodedString:message[@"body"] options:0];
    
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];
    [realm addObject:dbMessage];
    [realm commitWriteTransaction];

    return messageId;

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

- (NSMutableDictionary*)decodeMessage:(DatabaseMessage*)dbMessage withContact:(NSDictionary*)contact {

    NSMutableDictionary *message = [NSMutableDictionary dictionary];
    message[@"publicId"] = contact[@"publicId"];
    NSString *nickname = contact[@"nickname"];
    if (nickname != nil) {
        message[@"nickname"] = nickname;
    }
    message[@"contactId"] = [NSNumber numberWithInteger:dbMessage.contactId];
    message[@"messageId"] = [NSNumber numberWithInteger:dbMessage.messageId];
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

- (NSString*)decryptMessage:(NSDictionary *)message {

    NSDictionary *contact = [contactDatabase getContact:message[@"publicId"]];
    CKIVGenerator *ivGen = [[CKIVGenerator alloc] init];
    NSInteger sequence = [message[@"sequence"] integerValue];
    NSData *iv = [ivGen generate:sequence withNonce:contact[@"nonce"]];
    NSData *ciphertext = [[NSData alloc] initWithBase64EncodedString:message[@"body"] options:0];
    CKGCMCodec *codec = [[CKGCMCodec alloc] initWithData:ciphertext];
    [codec setIV:iv];
    NSArray *messageKeys = contact[@"messageKeys"];
    NSError *error = nil;
    NSInteger keyIndex = [message[@"keyIndex"] integerValue];
    [codec decrypt:messageKeys[keyIndex] withAuthData:contact[@"authData"] withError:&error];
    return [codec getString];

}

- (NSString*)decryptMessage:(DatabaseMessage*)message withContact:(NSDictionary*)contact {

    CKIVGenerator *ivGen = [[CKIVGenerator alloc] init];
    NSData *iv = [ivGen generate:message.sequence withNonce:contact[@"nonce"]];
    CKGCMCodec *codec = [[CKGCMCodec alloc] initWithData:message.message];
    [codec setIV:iv];
    NSArray *messageKeys = contact[@"messageKeys"];
    NSError *error = nil;
    [codec decrypt:messageKeys[message.keyIndex] withAuthData:contact[@"authData"] withError:&error];
    if (error == nil) {
        return [codec getString];
    }
    else {
        NSLog(@"MessagesDatabase.decryptMessage GCM decryption error - %@", error.localizedDescription);
        return @"";
    }

}

- (void)deleteAllMessages:(NSString*)publicId {

    RLMRealm *realm = [RLMRealm defaultRealm];
    Configurator *config = [ApplicationSingleton instance].config;
    NSInteger contactId = [config getContactId:publicId];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"contactId = %ld", contactId];
    RLMResults<DatabaseMessage*> *messages = [DatabaseMessage objectsWithPredicate:predicate];
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

- (NSArray*)loadConversation:(NSString*)publicId {

    NSMutableArray *conversation = [NSMutableArray array];
    Configurator *config = [ApplicationSingleton instance].config;
    NSInteger contactId = [config getContactId:publicId];
    NSDictionary *contact = [contactDatabase getContact:publicId];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"contactId = %ld", contactId];
    RLMResults<DatabaseMessage*> *messages = [[DatabaseMessage objectsWithPredicate:predicate]
                                              sortedResultsUsingKeyPath:@"timestamp" ascending:YES];
    for (DatabaseMessage *dbMessage in messages) {
        NSMutableDictionary *message = [self decodeMessage:dbMessage withContact:contact];
        [conversation addObject:message];
    }
    return conversation;

}

- (void)markMessageRead:(NSInteger)messageId {

    RLMRealm *realm = [RLMRealm defaultRealm];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"messageId = %ld", messageId];
    RLMResults<DatabaseMessage*> *messages = [DatabaseMessage objectsWithPredicate:predicate];
    if (messages.count > 0) {
        DatabaseMessage *dbMessage = [messages firstObject];
        [realm beginWriteTransaction];
        dbMessage.read = YES;
        [realm commitWriteTransaction];
    }
    else {
        NSLog(@"Message not in database!");
    }

}

- (NSDictionary*)mostRecentMessage:(NSInteger)contactId {

        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"contactId = %ld", contactId];
        RLMResults<DatabaseMessage*> *messages = [[DatabaseMessage objectsWithPredicate:predicate]
                                                  sortedResultsUsingKeyPath:@"timestamp" ascending:NO];
        if (messages.count > 0) {
            NSDictionary *contact = [contactDatabase getContactById:contactId];
            NSDictionary *message = [self decodeMessage:[messages firstObject] withContact:contact];
            return message;
        }
        else {
            NSLog(@"No messages found for contact %ld", contactId);
            return nil;
        }

}

- (NSArray*)pendingMessages {

    NSMutableArray *pending = [NSMutableArray array];
    Configurator *config = [ApplicationSingleton instance].config;
    NSArray *contactIds = [config allContactIds];
    for (NSNumber *cid in contactIds) {
        NSInteger contactId = [cid integerValue];
//        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"contactId = %ld", contactId];
        NSPredicate *predicate =
            [NSPredicate predicateWithFormat:@"contactId = %ld && acknowledged == %@", contactId, @NO];
        RLMResults<DatabaseMessage*> *messages = [DatabaseMessage objectsWithPredicate:predicate];
        for (DatabaseMessage *dbMessage in messages) {
            NSDictionary *contact = [contactDatabase getContactById:contactId];
            NSDictionary *message = [self decodeMessage:dbMessage withContact:contact];
            [pending addObject:message];
        }
    }
    return pending;

}
/*
- (NSArray*)reloadConversation:(NSString *)publicId {

    [conversations removeObjectForKey:publicId];
    return [self getConversation:publicId];

}
*/

@end
