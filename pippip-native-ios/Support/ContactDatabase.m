//
//  ContactDatabase.m
//  pippip-native-ios
//
//  Created by Steve Brenneis on 1/7/18.
//  Copyright © 2018 seComm. All rights reserved.
//

#import "ContactDatabase.h"
#import "CKGCMCodec.h"
#import "CKSecureRandom.h"
#import "DatabaseContact.h"
#import <Realm/Realm.h>

@interface ContactDatabase ()
{
    NSMutableDictionary *database;
    NSMutableArray *indexed;
}

@property (weak, nonatomic) SessionState *sessionState;

@end

@implementation ContactDatabase

- (instancetype)init {
    self = [super init];

    database = [NSMutableDictionary dictionary];
    indexed = [NSMutableArray array];

    return self;

}

- (void)addContact:(NSMutableDictionary *)contact {

    contact[@"index"] = [NSNumber numberWithInteger:[indexed count]];
    [indexed addObject:contact];
    NSString *publicId = contact[@"publicId"];
    database[publicId] = contact;

    // Assign a contact ID
    CKSecureRandom *rnd = [[CKSecureRandom alloc] init];
    NSInteger contactId = [rnd nextLong];
    contact[@"contactId"] = [NSNumber numberWithInteger:contactId];
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

}

- (NSInteger)contactCount {

    return database.count;

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

    NSDictionary *contact = database[publicId];
    NSNumber *cid = contact[@"contactId"];
    NSInteger contactId = [cid integerValue];
    NSNumber *index = contact[@"index"];
    [indexed removeObjectAtIndex:[index integerValue]];
    [database removeObjectForKey:publicId];
    // Delete from the realm
    RLMRealm *realm = [RLMRealm defaultRealm];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"contactId = %ld", contactId];
    RLMResults<DatabaseContact*> *contacts = [DatabaseContact objectsWithPredicate:predicate];
    if (contacts.count > 0) {
        if (realm != nil) {
            [realm beginWriteTransaction];
            [realm deleteObject:contacts[0]];
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

    return [codec encrypt:_sessionState.contactsKey withAuthData:_sessionState.authData];

}

- (NSDictionary*)getContactById:(NSString *)publicId {

    return database[publicId];

}

- (NSDictionary*)getContactByIndex:(NSInteger)index {

    return indexed[index];

}

- (NSArray*)getContacts:(NSString *)status {

    NSMutableArray *filtered = [NSMutableArray array];
    for (NSDictionary *contact in indexed) {
        NSString *currentStatus = contact[@"status"];
        if ([status isEqualToString:currentStatus]) {
            // Make the contact immutable
            [filtered addObject:[NSDictionary dictionaryWithDictionary:contact]];
        }
    }
    return filtered;

}

- (BOOL)loadContacts:(SessionState*)state {

    [database removeAllObjects];
    [indexed removeAllObjects];

    _sessionState = state;
    RLMRealm *realm = [RLMRealm defaultRealm];
    if (realm == nil) {
        return NO;
    }
    else {
        RLMResults<DatabaseContact*> *contacts = [DatabaseContact allObjects];
        NSInteger index = 0;
        for (DatabaseContact *dbContact in contacts) {
            NSMutableDictionary *contact = [self decodeContact:dbContact.encoded];
            if (contact != nil) {
                contact[@"contactId"] = [NSNumber numberWithInteger:dbContact.contactId];
                database[contact[@"publicId"]] = contact;
                contact[@"index"] = [NSNumber numberWithInteger:index];
                [indexed addObject:contact];
                index++;
            }
            else {
                return NO;
            }
        }
        return YES;
    }

}

- (void)syncContacts:(NSArray*)synched {

    while (indexed.count > 0) {
        NSDictionary *entity = indexed[0];
        [self deleteContact:entity[@"publicId"]];
    }

    for (NSMutableDictionary *entity in synched) {
        [self addContact:entity];
    }

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
    NSDictionary *entity = database[publicId];
    if (entity == nil) {
        // Not in the database.
        NSLog(@"Update contact, contact %@ not found", publicId);
    }
    else {
        // Transfer the contact ID and update the database
        NSNumber *cid = entity[@"contactId"];
        contact[@"contactId"] = cid;
        [self updateDatabaseContact:contact];
        // Update the cached contacts
        NSNumber *idx = entity[@"index"];
        contact[@"index"] = idx;
        NSInteger index = [idx integerValue];
        indexed[index] = contact;
        database[publicId] = contact;
    }

}

@end
