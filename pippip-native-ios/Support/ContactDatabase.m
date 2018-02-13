//
//  ContactDatabase.m
//  pippip-native-ios
//
//  Created by Steve Brenneis on 1/7/18.
//  Copyright © 2018 seComm. All rights reserved.
//

#import "ContactDatabase.h"
#import "CKGCMCodec.h"
#import "DatabaseContact.h"
#import "Configurator.h"
#import <Realm/Realm.h>

@interface ContactDatabase ()
{
    Configurator *config;
    NSMutableArray *indexed;
    NSMutableDictionary *keyed;
}

@property (weak, nonatomic) SessionState *sessionState;

@end

@implementation ContactDatabase

- (instancetype)initWithSessionState:(SessionState *)state {
    self = [super init];

    _sessionState = state;
    config = [[Configurator alloc] initWithSessionState:state];
    indexed = [NSMutableArray array];
    keyed = [NSMutableDictionary dictionary];

    return self;

}

- (NSInteger)addContact:(NSMutableDictionary *)contact {

    NSInteger contactId = [config newContactId];
    keyed[[NSNumber numberWithInteger:contactId]] = contact;
    NSString *publicId = contact[@"publicId"];
    keyed[publicId] = contact;
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

- (void)deleteContact:(NSString *)publicId {

    NSInteger contactId = [config getContactId:publicId];
    [config deleteContactId:publicId];
    [keyed removeObjectForKey:publicId];
    [keyed removeObjectForKey:[NSNumber numberWithInteger:contactId]];
    [indexed removeAllObjects];  // Invalidate the contact list so it is reloaded on the next request.
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
    
    NSMutableDictionary *contact = keyed[publicId];
    if (contact == nil) {
        NSInteger contactId = [config getContactId:publicId];
        if (contactId != NSNotFound) {
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"contactId = %ld", contactId];
            RLMResults<DatabaseContact*> *contacts = [DatabaseContact objectsWithPredicate:predicate];
            if (contacts.count > 0) {
                DatabaseContact *dbContact = [contacts firstObject];
                contact = [self decodeContact:dbContact.encoded];
                keyed[publicId] = contact;
                keyed[[NSNumber numberWithInteger:contactId]] = contact;
            }
        }
    }
    return contact;
    
}

- (NSMutableDictionary*)getContactById:(NSInteger)contactId {
    
    NSMutableDictionary *contact = keyed[[NSNumber numberWithInteger:contactId]];
    if (contact == nil) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"contactId = %ld", contactId];
        RLMResults<DatabaseContact*> *contacts = [DatabaseContact objectsWithPredicate:predicate];
        if (contacts.count > 0) {
            DatabaseContact *dbContact = [contacts firstObject];
            contact = [self decodeContact:dbContact.encoded];
            keyed[contact[@"publicId"]] = contact;
            keyed[[NSNumber numberWithInteger:contactId]] = contact;
        }
    }
    return contact;
    
}

- (NSArray*)getContactList {

    if (indexed.count == 0) {
        RLMResults<DatabaseContact*> *contacts = [DatabaseContact allObjects];
        for (DatabaseContact *dbContact in contacts) {
            // There might be a contact with ID = 0. This is a bug and can be ignored.
            NSInteger contactId = dbContact.contactId;
            if (contactId > 0) {
                NSMutableDictionary *contact = [self decodeContact:dbContact.encoded];
                if (contact != nil) {
                    [indexed addObject:contact];
                }
            }
        }
    }
    return indexed;

}

- (void)updateDatabaseContact:(NSDictionary*)contact {

    NSNumber *cid = contact[@"contactId"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"contactId = %ld", [cid integerValue]];
    RLMResults<DatabaseContact*> *contacts = [DatabaseContact objectsWithPredicate:predicate];
    if (contacts.count > 0) {
        DatabaseContact *dbContact = contacts[0];
        NSData *encoded = [self encodeContact:contact];
        RLMRealm *realm = [RLMRealm defaultRealm];
        if (realm != nil) {
            [realm beginWriteTransaction];
            dbContact.encoded = encoded;
            [realm commitWriteTransaction];
        }
    }

}

- (void)updateContact:(NSMutableDictionary*)contact {

    NSString *publicId = contact[@"publicId"];
    NSMutableDictionary *entity = [self getContact:publicId];
    if (entity == nil) {
        // Not in the database.
        NSLog(@"Update contact, contact %@ not found", publicId);
    }
    else {
        [self updateDatabaseContact:contact];
        // Invalidate the cached contacts
        [indexed removeAllObjects];
        [keyed removeObjectForKey:publicId];
        NSInteger contactId = [config getContactId:publicId];
        [keyed removeObjectForKey:[NSNumber numberWithInteger:contactId]];
    }

}

@end
