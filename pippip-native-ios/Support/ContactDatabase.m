//
//  ContactDatabase.m
//  pippip-native-ios
//
//  Created by Steve Brenneis on 1/7/18.
//  Copyright © 2018 seComm. All rights reserved.
//

#import "pippip_native_ios-Swift.h"
#import "ContactDatabase.h"
#import "CKGCMCodec.h"
#import "DatabaseContact.h"
#import "ApplicationSingleton.h"
#import "Notifications.h"
#import <Realm/Realm.h>

@interface ContactDatabase ()
{
    SessionState *sessionState;
    Configurator *config;
}

@end

@implementation ContactDatabase

- (instancetype)init {
    self = [super init];

    sessionState = [[SessionState alloc] init];
    config = [[Configurator alloc] init];

    return self;

}

- (void)addContact:(Contact*)contact {

    NSData *encoded = [self encodeContact:contact];

    // Add the contact to the database.
    DatabaseContact *dbContact = [[DatabaseContact alloc] init];
    dbContact.contactId = contact.contactId;
    dbContact.encoded = encoded;
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];
    [realm addObject:dbContact];
    [realm commitWriteTransaction];
    
}

- (Contact*)decodeContact:(NSData*)encoded withContactId:(NSInteger)contactId {

    CKGCMCodec *codec = [[CKGCMCodec alloc] initWithData:encoded];
    NSError *error = nil;
    [codec decrypt:sessionState.contactsKey withAuthData:sessionState.authData withError:&error];
    if (error != nil) {
        NSLog(@"Contact encoding error: %@", [error localizedDescription]);
        return nil;
    }
    Contact *contact = [[Contact alloc] init];
    contact.publicId = [codec getString];
    contact.status = [codec getString];
    NSString *nickname = [codec getString];
    if (nickname.length > 0) {  // Zero length nicknames are nil in the Contact object
        contact.nickname = nickname;
    }
    contact.timestamp = [codec getInt];
    NSInteger count = [codec getInt];
    if (count > 0) {
        NSMutableArray *messageKeys = [NSMutableArray array];
        while (messageKeys.count < count) {
            NSData *key = [codec getBlock];
            [messageKeys addObject:key];
        }
        contact.messageKeys = messageKeys;
        contact.authData = [codec getBlock];
        contact.nonce = [codec getBlock];
        contact.currentIndex = [codec getInt];
        contact.currentSequence = [codec getInt];
    }

    return contact;

}

- (BOOL)deleteContact:(NSInteger)contactId {

    RLMRealm *realm = [RLMRealm defaultRealm];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"contactId = %ld", contactId];
    RLMResults<DatabaseContact*> *contacts = [DatabaseContact objectsWithPredicate:predicate];
    if (contacts.count > 0) {
        DatabaseContact *dbContact = [contacts firstObject];
        [realm beginWriteTransaction];
        [realm deleteObject:dbContact];
        [realm commitWriteTransaction];
        return YES;
    }

    NSLog(@"Contact with ID %ld not found for delete", (long)contactId);

    return NO;

}

- (NSData*)encodeContact:(Contact*)contact {

    CKGCMCodec *codec = [[CKGCMCodec alloc] init];
    [codec putString:contact.publicId];
    [codec putString:contact.status];
    NSString *nickname = contact.nickname;
    if (nickname != nil) {
        [codec putString:nickname];
    }
    else {
        [codec putString:@""];
    }
    [codec putInt:contact.timestamp];
    NSArray *messageKeys = contact.messageKeys;
    if (messageKeys != nil) {
        [codec putInt:messageKeys.count];
        for (NSData *key in messageKeys) {
            [codec putBlock:key];
        }
        [codec putBlock:contact.authData];
        [codec putBlock:contact.nonce];
        [codec putInt:contact.currentIndex];
        [codec putInt:contact.currentSequence];
    }
    else {
        [codec putInt:0];
    }

    NSError *error = nil;
    NSData *encoded = [codec encrypt:sessionState.contactsKey withAuthData:sessionState.authData withError:&error];
    if (error != nil) {
        NSLog(@"Error while encrypting contact: %@", error.localizedDescription);
    }
    return encoded;

}

- (Contact*)getContact:(NSInteger)contactId {
    
    Contact *contact = nil;
    if (contactId != NSNotFound) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"contactId = %ld", contactId];
        RLMResults<DatabaseContact*> *contacts = [DatabaseContact objectsWithPredicate:predicate];
        if (contacts.count > 0) {
            DatabaseContact *dbContact = [contacts firstObject];
            contact = [self decodeContact:dbContact.encoded withContactId:contactId];
        }
    }
    return contact;
    
}
/*
- (Contact*)getContactById:(NSInteger)contactId {
    
    Contact *contact = nil;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"contactId = %ld", contactId];
    RLMResults<DatabaseContact*> *contacts = [DatabaseContact objectsWithPredicate:predicate];
    if (contacts.count > 0) {
        DatabaseContact *dbContact = [contacts firstObject];
        contact = [self decodeContact:dbContact.encoded];
    }
    return contact;
    
}
*/
- (NSArray<Contact*>*)getContactList {

    NSMutableArray *indexed = [NSMutableArray array];
    RLMResults<DatabaseContact*> *contacts = [DatabaseContact allObjects];
    for (DatabaseContact *dbContact in contacts) {
        // There might be a contact with ID = 0. This is a bug and can be ignored.
        NSInteger contactId = dbContact.contactId;
        if (dbContact.contactId > 0) {
            Contact *contact = [self decodeContact:dbContact.encoded withContactId:contactId];
            contact.contactId = contactId;
            if (contact != nil) {
                [indexed addObject:contact];
            }
        }
    }
    return indexed;

}

- (void)updateDatabaseContact:(Contact*)contact {

    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"contactId = %ld", contact.contactId];
    RLMResults<DatabaseContact*> *contacts = [DatabaseContact objectsWithPredicate:predicate];
    if (contacts.count > 0) {
        DatabaseContact *dbContact = [contacts firstObject];
        NSData *encoded = [self encodeContact:contact];
        RLMRealm *realm = [RLMRealm defaultRealm];
        [realm beginWriteTransaction];
        dbContact.encoded = encoded;
        [realm commitWriteTransaction];
    }

}

- (void)updateContacts:(NSArray<Contact*>*)contacts {

    for (Contact *contact in contacts) {
        Contact *entity = [self getContact:contact.contactId];
        if (entity == nil) {
            // Not in the database.
            NSLog(@"Update contact, contact %@ not found in database", contact.publicId);
        }
        else {
            [self updateDatabaseContact:contact];
        }
    }

}

@end
