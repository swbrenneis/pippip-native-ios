//
//  ContactManager.m
//  pippip-native-ios
//
//  Created by Steve Brenneis on 12/12/17.
//  Copyright © 2017 seComm. All rights reserved.
//

#import "ContactManager.h"
#import "pippip_native_ios-Swift.h"
#import "ApplicationSingleton.h"
#import "LoggingErrorDelegate.h"
#import "RESTSession.h"
#import "EnclaveRequest.h"
#import "EnclaveResponse.h"
#import "ContactDatabase.h"
#import "Notifications.h"

typedef enum REQUEST { MATCH_NICKNAME, ADD_FRIEND, DELETE_FRIEND, REQUEST_CONTACT,
                        ACKNOWLEDGE_REQUEST, GET_REQUESTS, DELETE_CONTACT, UPDATE_POLICY,
                        SYNC_CONTACTS, UPDATE_NICKNAME, UPDATE_PENDING_CONTACTS, NONE
} ContactRequest;

@interface ContactManager ()
{
    ContactRequest contactRequest;
    NSMutableArray<Contact*> *contactList;
    NSMutableDictionary<NSString*, Contact*> *contactMap;
    NSString *requestedNickname;
    NSString *acknowledgedNickname;
}

@property (weak, nonatomic) RESTSession *session;
@property (weak, nonatomic) ContactDatabase *contactDatabase;

@end

@implementation ContactManager

@synthesize errorDelegate;
@synthesize postPacket;

- (instancetype)init {
    self = [super init];
    
    _session = nil;
    _contactDatabase = [ApplicationSingleton instance].contactDatabase;
    contactMap = [NSMutableDictionary dictionary];
    contactRequest = NONE;
    errorDelegate = [[NotificationErrorDelegate alloc] initWithTitle:@"Contact Error"];

    [NSNotificationCenter.defaultCenter addObserver:self
                                           selector:@selector(contactsUpdated:)
                                               name:CONTACTS_UPDATED object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self
                                           selector:@selector(newSession:)
                                               name:NEW_SESSION object:nil];
    return self;
    
}

- (void)dealloc {

    [[NSNotificationCenter defaultCenter] removeObserver:self name:CONTACTS_UPDATED object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NEW_SESSION object:nil];

}

- (void)acknowledgeRequest:(NSString *)response withId:(NSString *)publicId withNickname:(NSString*) nickname {

    acknowledgedNickname = nickname;
    NSMutableDictionary *request = [NSMutableDictionary dictionary];
    request[@"method"] = @"AcknowledgeRequest";
    request[@"id"] = publicId;
    request[@"response"] = response;
    [self sendRequest:request with:ACKNOWLEDGE_REQUEST];
    
}

- (BOOL)addFriend:(NSString *)publicId {

    NSInteger found = [[ApplicationSingleton instance].config whitelistIndexOf:publicId];
    if (found == NSNotFound) {
        NSMutableDictionary *request = [NSMutableDictionary dictionary];
        request[@"method"] = @"UpdateWhitelist";
        request[@"action"] = @"add";
        request[@"id"] = publicId;
        [self sendRequest:request with:ADD_FRIEND];
        return YES;
    }
    else {
        return NO;
    }

}

- (void)contactsUpdated:(NSNotification*)notification {

    contactList = [[_contactDatabase getContactList] mutableCopy];
    [self mapContacts];

}

- (NSArray*)decodeKeys:(NSArray*)keyStrings {
    
    NSMutableArray *keys = [NSMutableArray array];
    for (NSString *key in keyStrings) {
        [keys addObject:[[NSData alloc] initWithBase64EncodedString:key options:0]];
    }
    return keys;
    
}

- (void)deleteContact:(NSString *)publicId {

    NSMutableDictionary *request = [NSMutableDictionary dictionary];
    request[@"method"] = @"DeleteContact";
    request[@"publicId"] = publicId;
    [self sendRequest:request with:DELETE_CONTACT];
    
}

- (void)deleteFriend:(NSString *)publicId {

    NSMutableDictionary *request = [NSMutableDictionary dictionary];
    request[@"method"] = @"UpdateWhitelist";
    request[@"action"] = @"delete";
    request[@"id"] = publicId;
    [self sendRequest:request with:DELETE_FRIEND];
    
}

- (void)dispatchResponse:(NSDictionary*)response {

    switch (contactRequest) {
        case ADD_FRIEND:
            NSLog(@"Add friend result - %@", response[@"result"]);
            [AsyncNotifier notifyWithName:FRIEND_ADDED object:nil userInfo:response];
            break;
        case DELETE_FRIEND:
            NSLog(@"Delete friend result - %@", response[@"result"]);
            [AsyncNotifier notifyWithName:FRIEND_DELETED object:nil userInfo:response];
            break;
        case DELETE_CONTACT:
        {
            [[ApplicationSingleton instance].conversationCache deleteAllMessages:response[@"publicId"]];
            NSArray *toDelete = [NSArray arrayWithObjects:response[@"publicId"], nil];
            [_contactDatabase deleteContacts:toDelete];
            contactList = [[_contactDatabase getContactList] mutableCopy];
            [AsyncNotifier notifyWithName:CONTACT_DELETED object:nil userInfo:response];
            [AsyncNotifier notifyWithName:MESSAGES_UPDATED object:nil userInfo:nil];
        }
            break;
        case MATCH_NICKNAME:
            [AsyncNotifier notifyWithName:NICKNAME_MATCHED object:nil userInfo:response];
            break;
        case REQUEST_CONTACT:
        {
            NSMutableDictionary *convert = [NSMutableDictionary dictionary];
            convert[@"publicId"] = response[@"requestedContactId"];
            convert[@"status"] = response[@"result"];
            if (requestedNickname != nil) {
                convert[@"nickname"] = requestedNickname;
            }
            Contact *contact = [[Contact alloc] init:convert];
            [_contactDatabase addContact:contact];  // Sends contacts updated notification
            [AsyncNotifier notifyWithName:CONTACT_REQUESTED object:contact userInfo:nil];
        }
            break;
        case UPDATE_NICKNAME:
            [AsyncNotifier notifyWithName:NICKNAME_UPDATED object:nil userInfo:response];
            break;
        case UPDATE_POLICY:
            [AsyncNotifier notifyWithName:POLICY_UPDATED object:nil userInfo:response];
            break;
        case GET_REQUESTS:
        {
            NSArray *requests = response[@"requests"];
            if (requests.count > 0) {
                [AsyncNotifier notifyWithName:REQUESTS_UPDATED object:requests userInfo:nil];
            }
        }
            break;
        case SYNC_CONTACTS:
        {
            NSInteger added = [response[@"added"] integerValue];
            NSInteger deleted = [response[@"deleted"] integerValue];
            NSInteger updated = [response[@"updated"] integerValue];
            NSLog(@"Contacts synchronized, %ld added, %ld updated, %ld deleted", added, updated, deleted);
            [AsyncNotifier notifyWithName:CONTACTS_SYNCRHONIZED object:nil userInfo:response];
        }
            break;
        case ACKNOWLEDGE_REQUEST:
        {
            NSDictionary *contact = response[@"acknowledged"];
            Contact *translated = [self translateContact:contact];
            if (translated != nil && [translated.status isEqualToString:@"accepted"]) {
                [_contactDatabase addContact:translated];
                [self loadContactList];
            }
//            NSArray *pending = response[@"pending"];
            NSArray *pending = [NSArray array];
            [AsyncNotifier notifyWithName:REQUEST_ACKNOWLEDGED object:pending userInfo:nil];
        }
            break;
        case UPDATE_PENDING_CONTACTS:
        {
            NSArray *contacts = response[@"contacts"];
            if (contacts != nil && contacts.count > 0)
            [self updateContacts:contacts];
            [AsyncNotifier notifyWithName:CONTACTS_UPDATED object:nil userInfo:nil];
        }
            break;
        case NONE:
            break;
    }

}

- (Contact*)getContact:(NSString *)publicId {

    return contactMap[publicId];

}

- (Contact*)getContactById:(NSInteger)contactId {

    [self loadContactList];
    for (Contact *contact in contactList) {
        if (contact.contactId == contactId) {
            return contact;
        }
    }
    return nil;

}

- (NSArray*)getContactList {

    [self loadContactList];
    return contactList;

}

- (NSString*)getContactPublicId:(NSString*)nickname {

    for (Contact *contact in contactList) {
        if ([contact.nickname isEqualToString:nickname]) {
            return contact.publicId;
        }
    }
    return nil;

}

- (NSArray<Contact*>*)getContacts:(NSString *)status {
    
    NSMutableArray *filtered = [NSMutableArray array];
    for (Contact *contact in contactList) {
        NSString *currentStatus = contact.status;
        if ([status isEqualToString:currentStatus]) {
            [filtered addObject:contact];
        }
    }
    return filtered;
    
}

- (void)getRequests {

    NSMutableDictionary *request = [NSMutableDictionary dictionary];
    request[@"method"] = @"GetPendingRequests";
    [self sendRequest:request with:GET_REQUESTS];
    
}

- (void)loadContactList {
    
    if (contactList == nil) {
        contactList = [[_contactDatabase getContactList] mutableCopy];
        [self mapContacts];
    }
    
}

- (void)mapContacts {

    [contactMap removeAllObjects];
    for (Contact *contact in contactList) {
        contactMap[contact.publicId] = contact;
    }

}

- (void)matchNickname:(NSString *)nickname withPublicId:(NSString *)publicId{

    NSMutableDictionary *request = [NSMutableDictionary dictionary];
    request[@"method"] = @"MatchNickname";
    if (nickname != nil) {
        request[@"nickname"] = nickname;
    }
    if (publicId != nil) {
        request[@"publicId"] = publicId;
    }
    [self sendRequest:request with:MATCH_NICKNAME];
    
}

- (void)newSession:(NSNotification*)notification {

    contactList = [[_contactDatabase getContactList] mutableCopy];
    [self mapContacts];

}

- (void)postComplete:(NSDictionary*)response {

    if (response != nil) {
        EnclaveResponse *enclaveResponse = [[EnclaveResponse alloc] init];
        if ([enclaveResponse processResponse:response errorDelegate:errorDelegate]) {
            NSDictionary *contactResponse = [enclaveResponse getResponse];
            [self dispatchResponse:contactResponse];
        }
    }
    contactRequest = NONE;

}

- (void)requestContact:(NSString*)publicId withNickname:(NSString *)nickname {

    requestedNickname = nickname;
    NSMutableDictionary *request = [NSMutableDictionary dictionary];
    request[@"method"] = @"RequestContact";
    request[@"id"] = publicId;
    [self sendRequest:request with:REQUEST_CONTACT];
    
}

/*
 * fragment should be upper case
 */
- (NSArray<Contact*>*)searchContacts:(NSString *)fragment {

    NSMutableArray *results = [NSMutableArray array];
    for (Contact *contact in contactList) {
        NSString *nickname = nil;
        if (contact.nickname != nil) {
            nickname = [contact.nickname uppercaseString];
        }
        NSString *publicId = [contact.publicId uppercaseString];
        if ([publicId containsString:fragment]) {
            [results addObject:contact];
        }
        else if (nickname != nil) {
            if ([nickname containsString:fragment]) {
                [results addObject:contact];
            }
        }
    }
    
    return results;

}

- (void)sendRequest:(NSDictionary*)request with:(ContactRequest)type {

    if (contactRequest == NONE) {
        contactRequest = type;
        if (_session == nil) {
            _session = [ApplicationSingleton instance].restSession;
        }
        
        EnclaveRequest *enclaveRequest = [[EnclaveRequest alloc] init];
        [enclaveRequest setRequest:request];
        
        postPacket = enclaveRequest;
        [_session queuePost:self];
    }
    else {
        NSLog(@"Contact manager request out of order");
    }
    
}

- (void)sessionComplete:(NSDictionary*)response {
    // Nothing to do here. Session is already established.
}

- (void)setContactPolicy:(NSString*)policy {

    NSMutableDictionary *request = [NSMutableDictionary dictionary];
    request[@"method"] = @"SetContactPolicy";
    request[@"policy"] = policy;
    [self sendRequest:request with:UPDATE_POLICY];

}

- (void)syncContacts {

    NSMutableDictionary *request = [NSMutableDictionary dictionary];
    NSArray *contactList = [_contactDatabase getContactList];
    NSMutableArray *syncList = [NSMutableArray array];
    for (Contact *contact in contactList) {
        Contact *sync = [[Contact alloc] init];
        sync.publicId = contact.publicId;
        sync.status = contact.status;
        sync.currentSequence = contact.currentSequence;
        sync.currentIndex = contact.currentIndex;
        sync.timestamp = contact.timestamp;
        [syncList addObject:sync];
    }
    request[@"method"] = @"SyncContacts";
    request[@"contacts"] = syncList;
    [self sendRequest:request with:SYNC_CONTACTS];

}

- (Contact*)translateContact:(NSDictionary*)serverContact {

    NSString *publicId = serverContact[@"publicId"];
    NSString *status = serverContact[@"status"];
    NSString *authData = serverContact[@"authData"];
    NSString *nonce = serverContact[@"nonce"];
    NSArray *keyStrings = serverContact[@"messageKeys"];
    if (publicId == nil || status == nil || authData == nil || keyStrings == nil || nonce == nil) {
        NSLog(@"Invalid server response in acknowledged contact");
        return nil;
    }
    else if ([status isEqualToString:@"accepted"]) {
        Contact *entity = [[Contact alloc] init];
        entity.publicId = publicId;
        if (acknowledgedNickname != nil) {
            entity.nickname = acknowledgedNickname;
        }
        entity.currentIndex = 0;
        entity.currentSequence = 0;
        entity.timestamp = [serverContact[@"timestamp"] integerValue];
        entity.status = status;
        NSData *adBytes = [[NSData alloc] initWithBase64EncodedString:authData options:0];
        NSData *nonceBytes = [[NSData alloc] initWithBase64EncodedString:nonce options:0];
        if (adBytes != nil && nonceBytes != nil) {
            entity.authData = adBytes;
            entity.nonce = nonceBytes;
            NSArray *keys = [self decodeKeys:keyStrings];
            if (keys != nil) {
                entity.messageKeys = keys;
                return entity;
            }
        }
        else {
            NSLog(@"Encoding error in translate contact");
        }
    }
    return nil;

}

- (void)updateContacts:(NSArray<NSDictionary*>*)serverContacts {
    
    NSMutableArray *updates = [NSMutableArray array];
    for (NSDictionary *serverContact in serverContacts) {
        NSString *publicId = serverContact[@"publicId"];
        Contact *update = contactMap[publicId];
        if (update == nil) {
            // Something really wrong here
            NSLog(@"Process contact, contact %@ does not exist", publicId);
        }
        else {
            NSString *status = serverContact[@"status"];
            update.status = status;
            update.timestamp = [serverContact[@"timestamp"] integerValue];
            if ([status isEqualToString:@"accepted"]) {
                update.currentSequence = 0;
                update.currentIndex = 0;
                update.authData = [[NSData alloc] initWithBase64EncodedString:serverContact[@"authData"] options:0];
                update.nonce = [[NSData alloc] initWithBase64EncodedString:serverContact[@"nonce"] options:0];
                NSArray *messageKeys = serverContact[@"messageKeys"];
                NSMutableArray *keys = [NSMutableArray array];
                for (NSString *keyString in messageKeys) {
                    NSData *key = [[NSData alloc] initWithBase64EncodedString:keyString options:0];
                    [keys addObject:key];
                }
                update.messageKeys = keys;
            }
            [updates addObject:update];
        }
    }
    [_contactDatabase updateContacts:updates];

}

- (void)updateNickname:(NSString *)nickname withOldNickname:(NSString *)oldNickname {

    NSMutableDictionary *request = [NSMutableDictionary dictionary];
    request[@"method"] = @"SetNickname";
    if (nickname != nil) {
        request[@"newNickname"] = nickname;
    }
    else {
        request[@"newNickname"] = @"";
    }
    if (oldNickname != nil) {
        request[@"oldNickname"] = oldNickname;
    }
    else {
        request[@"oldNickname"] = @"";
    }
    [self sendRequest:request with:UPDATE_NICKNAME];
    
}

- (NSUInteger)updatePendingContacts {

    NSMutableArray *pending = [NSMutableArray array];
    NSArray *filtered = [self getContacts:@"pending"];
    for (Contact *entity in filtered) {
        [pending addObject:entity.publicId];
    }
    if (pending.count > 0) {
        NSLog(@"%@", @"Updating pending contacts");
        NSMutableDictionary *request = [NSMutableDictionary dictionary];
        request[@"method"] = @"UpdatePendingContacts";
        request[@"pending"] = pending;
        [self sendRequest:request with:UPDATE_PENDING_CONTACTS];
    }
    return pending.count;

}

@end
