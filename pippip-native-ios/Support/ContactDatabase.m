//
//  ContactDatabase.m
//  pippip-native-ios
//
//  Created by Steve Brenneis on 1/7/18.
//  Copyright © 2018 seComm. All rights reserved.
//

#import "ContactDatabase.h"
#import "pippip_native_ios-Swift.h"
#import "CKGCMCodec.h"
#import "DatabaseContact.h"
#import "ApplicationSingleton.h"
#import "ApplicationSingleton.h"
#import "Notifications.h"
#import <Realm/Realm.h>

@interface ContactDatabase ()
{
}

@property (weak, nonatomic) SessionState *sessionState;

@end

@implementation ContactDatabase

- (instancetype)init {
    self = [super init];

    [NSNotificationCenter.defaultCenter addObserver:self
                                           selector:@selector(newSession:)
                                               name:NEW_SESSION object:nil];

    return self;

}

- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NEW_SESSION object:nil];
    
}

- (NSInteger)addContact:(NSMutableDictionary *)contact {

    Configurator *config = [ApplicationSingleton instance].config;
    NSInteger contactId = [config newContactId];
    NSString *publicId = contact[@"publicId"];
    [config addContactId:contactId withPublicId:publicId];

    NSData *encoded = [self encodeContact:contact];
    
    // Add the contact to the database.
    DatabaseContact *dbContact = [[DatabaseContact alloc] init];
    dbContact.contactId = contactId;
    dbContact.encoded = encoded;
    RLMRealm *realm = [RLMRealm defaultRealm];
    if (realm != nil) {
        [realm beginWriteTransaction];
        [realm addObject:dbContact];
        [realm commitWriteTransaction];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:CONTACTS_UPDATED object:nil];
    return contactId;

}

- (NSMutableDictionary*)decodeContact:(NSData*)encoded {

    CKGCMCodec *codec = [[CKGCMCodec alloc] initWithData:encoded];
    NSError *error = nil;
    [codec decrypt:_sessionState.contactsKey withAuthData:_sessionState.authData withError:&error];
    if (error != nil) {
        NSLog(@"Contact encoding error: %@", [error localizedDescription]);
        return nil;
    }
    NSMutableDictionary *contact = [NSMutableDictionary dictionary];
    contact[@"publicId"] = [codec getString];
    contact[@"status"] = [codec getString];
    NSString *nickname = [codec getString];
    if (nickname.length > 0) {
        contact[@"nickname"] = nickname;
    }
    contact[@"timestamp"] = [NSNumber numberWithLong:[codec getInt]];
    NSInteger count = [codec getInt];
    if (count > 0) {
        NSMutableArray *messageKeys = [NSMutableArray array];
        while (messageKeys.count < count) {
            NSData *key = [codec getBlock];
            [messageKeys addObject:key];
        }
        contact[@"messageKeys"] = messageKeys;
        contact[@"authData"] = [codec getBlock];
        contact[@"nonce"] = [codec getBlock];
        contact[@"currentIndex"] = [NSNumber numberWithLong:[codec getInt]];
        contact[@"currentSequence"] = [NSNumber numberWithLong:[codec getInt]];
    }

    return contact;

}

- (BOOL)deleteContact:(NSString*)publicId {

    RLMRealm *realm = [RLMRealm defaultRealm];
    RLMResults<DatabaseContact*> *contacts = [DatabaseContact allObjects];
    for (DatabaseContact *dbContact in contacts) {
        NSDictionary *contact = [self decodeContact:dbContact.encoded];
        if ([publicId isEqualToString:contact[@"publicId"]]) {
            [realm beginWriteTransaction];
            [realm deleteObject:dbContact];
            [realm commitWriteTransaction];
            return YES;
        }
    }
    return NO;

}

- (void)deleteContacts:(NSArray*)contacts {

    Configurator *config = [ApplicationSingleton instance].config;
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
    [[NSNotificationCenter defaultCenter] postNotificationName:CONTACTS_UPDATED object:nil];

}

- (NSData*)encodeContact:(NSDictionary*)contact {

    CKGCMCodec *codec = [[CKGCMCodec alloc] init];
    [codec putString:contact[@"publicId"]];
    [codec putString:contact[@"status"]];
    NSString *nickname = contact[@"nickname"];
    if (nickname != nil) {
        [codec putString:nickname];
    }
    else {
        [codec putString:@""];
    }
    NSNumber *timestamp = contact[@"timestamp"];
    [codec putInt:[timestamp integerValue]];
    NSArray *messageKeys = contact[@"messageKeys"];
    if (messageKeys != nil) {
        [codec putInt:messageKeys.count];
        for (NSData *key in messageKeys) {
            [codec putBlock:key];
        }
        [codec putBlock:contact[@"authData"]];
        [codec putBlock:contact[@"nonce"]];
        NSNumber *currentIndex = contact[@"currentIndex"];
        [codec putInt:[currentIndex integerValue]];
        NSNumber *currentSequence = contact[@"currentSequence"];
        [codec putInt:[currentSequence integerValue]];
    }
    else {
        [codec putInt:0];
    }

    NSError *error = nil;
    NSData *encoded = [codec encrypt:_sessionState.contactsKey withAuthData:_sessionState.authData withError:&error];
    if (error != nil) {
        NSLog(@"Error while encrypting contact: %@", error.localizedDescription);
    }
    return encoded;

}

- (NSMutableDictionary*)getContact:(NSString *)publicId {
    
    NSMutableDictionary *contact = nil;
    Configurator *config = [ApplicationSingleton instance].config;
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

- (NSMutableDictionary*)getContactById:(NSInteger)contactId {
    
    NSMutableDictionary *contact = nil;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"contactId = %ld", contactId];
    RLMResults<DatabaseContact*> *contacts = [DatabaseContact objectsWithPredicate:predicate];
    if (contacts.count > 0) {
        DatabaseContact *dbContact = [contacts firstObject];
        contact = [self decodeContact:dbContact.encoded];
    }
    return contact;
    
}

- (NSArray*)getContactList {

    NSMutableArray *indexed = [NSMutableArray array];
    RLMResults<DatabaseContact*> *contacts = [DatabaseContact allObjects];
    for (DatabaseContact *dbContact in contacts) {
        // There might be a contact with ID = 0. This is a bug and can be ignored.
        NSInteger contactId = dbContact.contactId;
        if (contactId > 0) {
            NSMutableDictionary *contact = [self decodeContact:dbContact.encoded];
            contact[@"contactId"] = [NSNumber numberWithInteger:contactId];
            if (contact != nil) {
                [indexed addObject:contact];
            }
        }
    }
    return indexed;

}

- (void)newSession:(NSNotification*)notification {

    _sessionState = notification.object;

}

- (void)updateDatabaseContact:(NSDictionary*)contact withContactId:(NSInteger)contactId{

    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"contactId = %ld", contactId];
    RLMResults<DatabaseContact*> *contacts = [DatabaseContact objectsWithPredicate:predicate];
    if (contacts.count > 0) {
        DatabaseContact *dbContact = [contacts firstObject];
        NSData *encoded = [self encodeContact:contact];
        RLMRealm *realm = [RLMRealm defaultRealm];
        if (realm != nil) {
            [realm beginWriteTransaction];
            dbContact.encoded = encoded;
            [realm commitWriteTransaction];
        }
    }

}

- (void)updateContacts:(NSArray*)contacts {

    for (NSMutableDictionary *contact in contacts) {
        NSString *publicId = contact[@"publicId"];
        NSMutableDictionary *entity = [self getContact:publicId];
        if (entity == nil) {
            // Not in the database.
            NSLog(@"Update contact, contact %@ not found", publicId);
        }
        else {
            Configurator *config = [ApplicationSingleton instance].config;
            NSInteger contactId = [config getContactId:publicId];
            [self updateDatabaseContact:contact withContactId:contactId];
        }
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:CONTACTS_UPDATED object:nil];

}

@end
