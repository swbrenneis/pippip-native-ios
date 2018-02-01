//
//  ContactDatabase.m
//  pippip-native-ios
//
//  Created by Steve Brenneis on 1/7/18.
//  Copyright © 2018 seComm. All rights reserved.
//

#import "ContactDatabase.h"
#import "CKGCMCodec.h"

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

- (void)addContact:(NSMutableDictionary *)contact withId:(NSString *)publicId {

    contact[@"index"] = [NSNumber numberWithInteger:[indexed count]];
    [indexed addObject:contact];
    database[publicId] = contact;

}

- (NSInteger)contactCount {

    return database.count;

}

- (NSMutableDictionary*)decodeContact:(NSDictionary*)encoded {

    NSMutableDictionary *contact = [NSMutableDictionary dictionary];
    contact[@"publicId"] = encoded[@"publicId"];
    contact[@"status"] = encoded[@"status"];
    NSString *nickname = encoded[@"nickname"];
    if (nickname != nil) {
        contact[@"nickname"] = nickname;
    }
    contact[@"currentIndex"] = encoded[@"currentIndex"];
    contact[@"currentSequence"] = encoded[@"currentSequence"];
    contact[@"timestamp"] = encoded[@"timestamp"];
    NSString *authData = encoded[@"authData"];
    if (authData != nil) {
        contact[@"authData"] = [[NSData alloc] initWithBase64EncodedString:authData options:0];
        NSArray *encodedKeys = encoded[@"messageKeys"];
        NSMutableArray *messageKeys = [NSMutableArray array];
        for (NSString *encodedKey in encodedKeys) {
            NSData *key = [[NSData alloc] initWithBase64EncodedString:encodedKey options:0];
            [messageKeys addObject:key];
        }
        contact[@"messageKeys"] = messageKeys;
    }

    return contact;

}

- (void)decodeDatabase:(NSData*)encoded withError:(NSError**) error {

    *error = nil;
    CKGCMCodec *codec = [[CKGCMCodec alloc] initWithData:encoded];
    [codec decrypt:_sessionState.contactsKey withAuthData:_sessionState.authData withError:error];
    // TODO Handle errors
    if (*error == nil) {
        NSInteger count = [codec getInt];
        NSInteger index = 0;
        while (database.count < count && *error == nil) {
            NSString *publicId = [codec getString];
            NSData *json = [codec getBlock];
            NSMutableDictionary *contact = [NSJSONSerialization JSONObjectWithData:json
                                                                           options:NSJSONReadingMutableContainers
                                                                             error:error];
            if (contact != nil) {
                NSMutableDictionary *decoded = [self decodeContact:contact];
                decoded[@"index"] = [NSNumber numberWithInteger:index];
                database[publicId] = decoded;
                [indexed addObject:decoded];
                index++;
            }
        }
    }

}

- (void)deleteContact:(NSString *)publicId {

    NSDictionary *contact = database[publicId];
    NSNumber *index = contact[@"index"];
    [indexed removeObjectAtIndex:[index integerValue]];
    [database removeObjectForKey:publicId];

}

- (NSDictionary*)encodeContact:(NSDictionary*)contact {

    NSMutableDictionary *encoded = [NSMutableDictionary dictionary];
    encoded[@"publicId"] = contact[@"publicId"];
    encoded[@"status"] = contact[@"status"];
    NSString *nickname = contact[@"nickname"];
    if (nickname != nil) {
        encoded[@"nickname"] = nickname;
    }
    encoded[@"currentIndex"] = contact[@"currentIndex"];
    encoded[@"currentSequence"] = contact[@"currentSequence"];
    encoded[@"timestamp"] = contact[@"timestamp"];
    NSData *authData = contact[@"authData"];
    if (authData != nil) {
        encoded[@"authData"] = [authData base64EncodedStringWithOptions:0];
        NSArray *messageKeys = contact[@"messageKeys"];
        NSMutableArray *encodedKeys = [NSMutableArray array];
        for (NSData *key in messageKeys) {
            NSString *encodedKey = [key base64EncodedStringWithOptions:0];
            [encodedKeys addObject:encodedKey];
        }
        encoded[@"messageKeys"] = encodedKeys;
    }

    return encoded;

}

- (NSData*)encodeDatabase {

    CKGCMCodec *codec = [[CKGCMCodec alloc] init];
    [codec putInt:database.count];
    NSString *key;
    NSEnumerator *enumerator = [database keyEnumerator];
    while ((key = [enumerator nextObject])) {
        NSMutableDictionary *contact = database[key];
        NSDictionary *encoded = [self encodeContact:contact];
        NSError *jsonError;
        NSData *json = [NSJSONSerialization dataWithJSONObject:encoded
                                                       options:0
                                                         error:&jsonError];
        // TODO Handle errors
        if (json != nil) {
            [codec putString:key];
            [codec putBlock:json];
        }
    }
    return [codec encrypt:_sessionState.contactsKey withAuthData:_sessionState.authData];

}

- (NSMutableDictionary*)getContact:(NSString *)publicId {

    return database[publicId];

}

- (NSMutableDictionary*)getContactByIndex:(NSInteger)index {

    return indexed[index];

}

- (NSArray*)getContacts:(NSString *)status {

    NSMutableArray *filtered = [NSMutableArray array];
    for (NSDictionary *contact in indexed) {
        NSString *currentStatus = contact[@"status"];
        if ([status isEqualToString:currentStatus]) {
            [filtered addObject:contact];
        }
    }
    return filtered;

}

- (void)loadContacts:(SessionState*)state {

    _sessionState = state;
    
    [database removeAllObjects];
    [indexed removeAllObjects];

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docPath = [paths objectAtIndex:0];
    NSString *configsPath = [docPath stringByAppendingPathComponent:@"PippipConfig"];
    NSString *dbFileName = [_sessionState.currentAccount stringByAppendingString:@".contacts"];
    NSString *contactsPath = [configsPath stringByAppendingPathComponent:dbFileName];

    if ([[NSFileManager defaultManager] fileExistsAtPath:contactsPath]) {
        NSData *dbData = [[NSFileManager defaultManager] contentsAtPath:contactsPath];
        NSError *error;
        [self decodeDatabase:dbData withError:&error];
        if (error != nil) {
            NSLog(@"%@, %@", @"Contact database decoding error", [error localizedDescription]);
        }
    }

}

- (void)storeContacts:(NSString*)accountName {

    NSData *encoded = [self encodeDatabase];
    if (encoded != nil) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *docPath = [paths objectAtIndex:0];
        NSString *configsPath = [docPath stringByAppendingPathComponent:@"PippipConfig"];
        NSString *dbFileName = [accountName stringByAppendingString:@".contacts"];
        NSString *contactsPath = [configsPath stringByAppendingPathComponent:dbFileName];
        [encoded writeToFile:contactsPath atomically:YES];
    }

}

- (void)syncContacts:(NSMutableArray *)synched {

    [indexed removeAllObjects];
    [database removeAllObjects];
    for (NSMutableDictionary *entity in synched) {
        [indexed addObject:entity];
        database[entity[@"publicId"]] = entity;
    }

}

@end
