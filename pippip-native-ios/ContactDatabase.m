//
//  ContactDatabase.m
//  pippip-native-ios
//
//  Created by Steve Brenneis on 1/7/18.
//  Copyright © 2018 seComm. All rights reserved.
//

#import "ContactDatabase.h"
#import "CKGCMCodec.h"
#import "AppDelegate.h"
#import "AccountManager.h"

@interface ContactDatabase ()
{
    NSMutableDictionary *database;
    NSMutableArray *indexed;
}

@property (weak, nonatomic) AccountManager *accountManager;

@end

@implementation ContactDatabase

- (instancetype)initWithAccountManager:(AccountManager *)manager {
    self = [super init];

    _accountManager = manager;
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

- (void)decodeDatabase:(NSData*)encoded withError:(NSError**) error {

    *error = nil;
    SessionState *state = _accountManager.sessionState;
    CKGCMCodec *codec = [[CKGCMCodec alloc] initWithData:encoded];
    [codec decrypt:state.contactsKey withAuthData:state.authData withError:error];
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
                contact[@"index"] = [NSNumber numberWithInteger:index];
                database[publicId] = contact;
                [indexed addObject:contact];
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

- (NSData*)encodeDatabase {

    SessionState *state = _accountManager.sessionState;
    CKGCMCodec *codec = [[CKGCMCodec alloc] init];
    [codec putInt:database.count];
    NSString *key;
    NSEnumerator *enumerator = [database keyEnumerator];
    while ((key = [enumerator nextObject])) {
        NSMutableDictionary *contact = database[key];
        // Remove the index before storing
        [contact removeObjectForKey:@"index"];
        NSError *jsonError;
        NSData *json = [NSJSONSerialization dataWithJSONObject:contact
                                                       options:0
                                                         error:&jsonError];
        // TODO Handle errors
        if (json != nil) {
            [codec putString:key];
            [codec putBlock:json];
        }
    }
    return [codec encrypt:state.contactsKey withAuthData:state.authData];

}

- (NSMutableDictionary*)getContact:(NSString *)publicId {

    return database[publicId];

}

- (NSMutableDictionary*)getContactByIndex:(NSInteger)index {

    return indexed[index];

}

- (void)loadContacts {

    [database removeAllObjects];
    [indexed removeAllObjects];

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docPath = [paths objectAtIndex:0];
    NSString *configsPath = [docPath stringByAppendingPathComponent:@"PippipConfig"];
    NSString *dbFileName = [_accountManager.currentAccount stringByAppendingString:@".contacts"];
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

- (void)storeContacts {

    NSData *encoded = [self encodeDatabase];
    if (encoded != nil) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *docPath = [paths objectAtIndex:0];
        NSString *configsPath = [docPath stringByAppendingPathComponent:@"PippipConfig"];
        NSString *dbFileName = [_accountManager.currentAccount stringByAppendingString:@".contacts"];
        NSString *contactsPath = [configsPath stringByAppendingPathComponent:dbFileName];
        [encoded writeToFile:contactsPath atomically:YES];
    }

}

@end
