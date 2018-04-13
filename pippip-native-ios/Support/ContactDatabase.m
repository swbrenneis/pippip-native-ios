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
#import "Configurator.h"
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

- (NSInteger)addContact:(Contact*)contact {

    NSInteger contactId = [config newContactId:contact.publicId];
    contact.contactId = contactId;
    NSData *encoded = [self encodeContact:contact];

    // Add the contact to the database.
    DatabaseContact *dbContact = [[DatabaseContact alloc] init];
    dbContact.contactId = contactId;
    dbContact.encoded = encoded;
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];
    [realm addObject:dbContact];
    [realm commitWriteTransaction];

    return contactId;

}

- (Contact*)decodeContact:(NSData*)encoded {

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

- (BOOL)deleteContact:(NSString*)publicId {

    RLMRealm *realm = [RLMRealm defaultRealm];
    RLMResults<DatabaseContact*> *contacts = [DatabaseContact allObjects];
    for (DatabaseContact *dbContact in contacts) {
        Contact *contact = [self decodeContact:dbContact.encoded];
        if ([publicId isEqualToString:contact.publicId]) {
            [realm beginWriteTransaction];
            [realm deleteObject:dbContact];
            [realm commitWriteTransaction];
            return YES;
        }
    }
    return NO;

}

- (void)deleteContacts:(NSArray<NSString*>*)contacts {

    for (NSString *publicId in contacts) {
        NSInteger contactId = [config getContactId:publicId];
        if (contactId == NSNotFound) {
            // We lost the contact ID, possibly due to crash.
            [self deleteContact:publicId];
        }
        else {
            [config deleteContactId:publicId];
            // Delete from the realm
            RLMRealm *realm = [RLMRealm defaultRealm];
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"contactId = %ld", contactId];
            RLMResults<DatabaseContact*> *contacts = [DatabaseContact objectsWithPredicate:predicate];
            if (contacts.count > 0) {
                if (realm != nil) {
                    [realm beginWriteTransaction];
                    [realm deleteObject:[contacts firstObject]];
                    [realm commitWriteTransaction];
                }
            }
        }
    }

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

- (Contact*)getContact:(NSString *)publicId {
    
    Contact *contact = nil;
    NSInteger contactId = [config getContactId:publicId];
    if (contactId != NSNotFound) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"contactId = %ld", contactId];
        RLMResults<DatabaseContact*> *contacts = [DatabaseContact objectsWithPredicate:predicate];
        if (contacts.count > 0) {
            DatabaseContact *dbContact = [contacts firstObject];
            contact = [self decodeContact:dbContact.encoded];
        }
    }
    return contact;
    
}

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

- (NSArray<Contact*>*)getContactList {

    NSMutableArray *indexed = [NSMutableArray array];
    RLMResults<DatabaseContact*> *contacts = [DatabaseContact allObjects];
    for (DatabaseContact *dbContact in contacts) {
        // There might be a contact with ID = 0. This is a bug and can be ignored.
        NSInteger contactId = dbContact.contactId;
        if (dbContact.contactId > 0) {
            Contact *contact = [self decodeContact:dbContact.encoded];
            contact.contactId = contactId;
            if (contact != nil) {
                [indexed addObject:contact];
            }
        }
    }
    return indexed;

}

- (void)updateDatabaseContact:(Contact*)contact withContactId:(NSInteger)contactId{

    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"contactId = %ld", contactId];
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
        Contact *entity = [self getContact:contact.publicId];
        if (entity == nil) {
            // Not in the database.
            NSLog(@"Update contact, contact %@ not found in database", contact.publicId);
        }
        else {
            NSInteger contactId = [config getContactId:contact.publicId];
            [self updateDatabaseContact:contact withContactId:contactId];
        }
    }

}

@end
