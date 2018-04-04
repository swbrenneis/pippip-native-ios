//
//  MessagesDatabase.m
//  pippip-native-ios
//
//  Created by Steve Brenneis on 1/29/18.
//  Copyright © 2018 seComm. All rights reserved.
//

#import <Realm/Realm.h>
#import "MessagesDatabase.h"
#import "pippip_native_ios-Swift.h"
#import "ApplicationSingleton.h"
#import "DatabaseMessage.h"
#import "ContactManager.h"
#import "Configurator.h"
#import "CKIVGenerator.h"
#import "CKGCMCodec.h"

static const float CURRENT_VERSION = 1.0;

@interface MessagesDatabase ()
{
    NSInteger messageId;
    ContactManager *contactManager;
}

@property (weak, nonatomic) SessionState *sessionState;

@end

@implementation MessagesDatabase

- (instancetype)init {
    self = [super init];

    contactManager = [[ContactManager alloc] init];

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
    dbMessage.version = CURRENT_VERSION;
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
    if ([[ApplicationSingleton instance].config getCleartextMessages]) {
        dbMessage.cleartext = [self decryptMessage:message];
    }
    
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

- (NSMutableDictionary*)decodeMessage:(DatabaseMessage*)dbMessage withContact:(Contact*)contact {

    NSMutableDictionary *message = [NSMutableDictionary dictionary];
    message[@"publicId"] = contact.publicId;
    NSString *nickname = contact.nickname;
    if (nickname != nil) {
        message[@"nickname"] = nickname;
    }
    message[@"contactId"] = [NSNumber numberWithInteger:dbMessage.contactId];
    message[@"messageId"] = [NSNumber numberWithInteger:dbMessage.messageId];
    message[@"messageType"] = dbMessage.messageType;
    message[@"read"] = [NSNumber numberWithBool:dbMessage.read];
    message[@"acknowledged"] = [NSNumber numberWithBool:dbMessage.acknowledged];
    message[@"timestamp"] = [NSNumber numberWithInteger:dbMessage.timestamp];
    message[@"sequence"] = [NSNumber numberWithInteger:dbMessage.sequence];
    message[@"sent"] = [NSNumber numberWithBool:dbMessage.sent];
    if ([[ApplicationSingleton instance].config getCleartextMessages]) {
        message[@"cleartext"] = dbMessage.cleartext;
    }
    else {
        message[@"cleartext"] = [self decryptMessage:dbMessage withContact:contact];
    }
    return message;

}

- (void)decryptAll {

    RLMRealm *realm = [RLMRealm defaultRealm];
    RLMResults<DatabaseMessage*> *messages = [DatabaseMessage allObjects];
    for (DatabaseMessage *dbMessage in messages) {
        Contact *contact = [contactManager getContactById:dbMessage.contactId];
        [realm beginWriteTransaction];
        dbMessage.cleartext = [self decryptMessage:dbMessage withContact:contact];
        [realm commitWriteTransaction];
    }
    
}

- (NSString*)decryptMessage:(NSDictionary *)message {

    Contact *contact = [contactManager getContact:message[@"publicId"]];
    CKIVGenerator *ivGen = [[CKIVGenerator alloc] init];
    NSInteger sequence = [message[@"sequence"] integerValue];
    NSData *iv = [ivGen generate:sequence withNonce:contact.nonce];
    NSData *ciphertext = [[NSData alloc] initWithBase64EncodedString:message[@"body"] options:0];
    CKGCMCodec *codec = [[CKGCMCodec alloc] initWithData:ciphertext];
    [codec setIV:iv];
    NSArray *messageKeys = contact.messageKeys;
    NSError *error = nil;
    NSInteger keyIndex = [message[@"keyIndex"] integerValue];
    [codec decrypt:messageKeys[keyIndex] withAuthData:contact.authData withError:&error];
    if (error != nil) {
        NSLog(@"MessagesDatabase.decryptMessage GCM decryption error - %@", error.localizedDescription);
        return @"";
    }
    else {
        return [codec getString];
    }

}

- (NSString*)decryptMessage:(DatabaseMessage*)message withContact:(Contact*)contact {

    CKIVGenerator *ivGen = [[CKIVGenerator alloc] init];
    NSData *iv = [ivGen generate:message.sequence withNonce:contact.nonce];
    CKGCMCodec *codec = [[CKGCMCodec alloc] initWithData:message.message];
    [codec setIV:iv];
    NSArray *messageKeys = contact.messageKeys;
    NSError *error = nil;
    [codec decrypt:messageKeys[message.keyIndex] withAuthData:contact.authData withError:&error];
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

- (NSMutableDictionary*)loadMessage:(NSInteger)messageId withPublicId:(NSString*)publicId {

    Contact *contact = [contactManager getContact:publicId];
    NSInteger contactId = [[ApplicationSingleton instance].config getContactId:publicId];
    NSPredicate *predicate =
        [NSPredicate predicateWithFormat:@"messageId = %ld && contactId = %ld", messageId, contactId];
    RLMResults<DatabaseMessage*> *messages = [[DatabaseMessage objectsWithPredicate:predicate]
                                              sortedResultsUsingKeyPath:@"timestamp" ascending:YES];
    if (messages.count > 0) {
        DatabaseMessage *dbMessage = [messages firstObject];
        if (dbMessage.message == nil) { // Clean it up.
            RLMRealm *realm = [RLMRealm defaultRealm];
            [realm beginWriteTransaction];
            [realm deleteObject:dbMessage];
            [realm commitWriteTransaction];
            return nil;
        }
        else {
            return [self decodeMessage:dbMessage withContact:contact];
        }
    }
    else {
        NSLog(@"Mesage with id %ld for contact with id %ld does not exist", messageId, contactId);
        return nil;
    }

}

- (NSArray*)loadMessageIds:(NSInteger)contactId {

    NSMutableArray *messageIds = [NSMutableArray array];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"contactId = %ld", contactId];
    RLMResults<DatabaseMessage*> *messages =
        [[DatabaseMessage objectsWithPredicate:predicate] sortedResultsUsingDescriptors:@[
                                    [RLMSortDescriptor sortDescriptorWithKeyPath:@"timestamp" ascending:YES]
                                    ]];
    for (DatabaseMessage *dbMessage in messages) {
        [messageIds addObject:[NSNumber numberWithInteger:dbMessage.messageId]];
    }
    return messageIds;

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
        Contact *contact = [contactManager getContactById:contactId];
        NSDictionary *message = [self decodeMessage:[messages firstObject] withContact:contact];
        return message;
    }
    else {
        NSLog(@"No messages found for contact %ld", contactId);
        return nil;
    }

}

- (NSArray*)pendingMessageInfo {

    NSMutableArray *pending = [NSMutableArray array];
    Configurator *config = [ApplicationSingleton instance].config;
    NSArray *contactIds = [config allContactIds];
    for (NSNumber *cid in contactIds) {
        NSInteger contactId = [cid integerValue];
        Contact *contact = [contactManager getContactById:contactId];
        NSPredicate *predicate =
            [NSPredicate predicateWithFormat:@"contactId = %ld && acknowledged == %@", contactId, @NO];
        RLMResults<DatabaseMessage*> *messages = [DatabaseMessage objectsWithPredicate:predicate];
        NSLog(@"%ld pending messages in database", messages.count);
        NSInteger count = 1;
        for (DatabaseMessage *dbMessage in messages) {
            NSLog(@"Adding message %ld of %ld", count++, messages.count);
            NSMutableDictionary *info = [NSMutableDictionary dictionary];
            info[@"publicId"] = contact.publicId;
            info[@"sequence"] = [NSNumber numberWithInteger:dbMessage.sequence];
            info[@"timestamp"] = [NSNumber numberWithInteger:dbMessage.timestamp];
            [pending addObject:info];
        }
    }
    return pending;

}

- (void)scrubCleartext {

    RLMRealm *realm = [RLMRealm defaultRealm];
    RLMResults<DatabaseMessage*> *messages = [DatabaseMessage allObjects];
    for (DatabaseMessage *dbMessage in messages) {
        [realm beginWriteTransaction];
        dbMessage.cleartext = nil;
        [realm commitWriteTransaction];
    }

}
/*
- (NSArray*)unreadMessageIds:(NSString *)publicId {

    NSMutableArray *unread = [NSMutableArray array];
    NSInteger contactId = [[ApplicationSingleton instance].config getContactId:publicId];
    NSPredicate *predicate =
        [NSPredicate predicateWithFormat:@"contactId = %ld && read == %@", contactId, @NO];
    RLMResults<DatabaseMessage*> *messages = [DatabaseMessage objectsWithPredicate:predicate];
    for (DatabaseMessage *dbMessage in messages) {
        [unread addObject:[NSNumber numberWithInteger:dbMessage.messageId]];
    }
    return unread;

}
*/
@end
