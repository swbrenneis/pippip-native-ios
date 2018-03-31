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
//#import "CKGCMCodec.h"

typedef enum REQUEST { MATCH_NICKNAME, ADD_FRIEND, DELETE_FRIEND, REQUEST_CONTACT,
                        ACKNOWLEDGE_REQUEST, GET_REQUESTS, DELETE_CONTACT, UPDATE_POLICY,
                        SYNC_CONTACTS, UPDATE_NICKNAME, UPDATE_PENDING_CONTACTS, NONE
} ContactRequest;

@interface ContactManager ()
{
    ContactRequest contactRequest;
    NSMutableArray *contactList;
    NSMutableDictionary *contactMap;
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
    
    [NSNotificationCenter.defaultCenter addObserver:self
                                           selector:@selector(contactsUpdated:)
                                               name:CONTACTS_UPDATED object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self
                                           selector:@selector(newSession:)
                                               name:NEW_SESSION object:nil];
    errorDelegate = self;
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
            NSMutableDictionary *contact = [NSMutableDictionary dictionary];
            contact[@"publicId"] = response[@"requestedContactId"];
            contact[@"status"] = response[@"result"];
            if (requestedNickname != nil) {
                contact[@"nickname"] = requestedNickname;
            }
            [_contactDatabase addContact:contact];  // Sends contacts updated notification
            [AsyncNotifier notifyWithName:CONTACT_REQUESTED object:nil userInfo:contact];
        }
            break;
        case UPDATE_NICKNAME:
            [AsyncNotifier notifyWithName:NICKNAME_UPDATED object:nil userInfo:response];
            break;
        case UPDATE_POLICY:
            [AsyncNotifier notifyWithName:POLICY_UPDATED object:nil userInfo:response];
            break;
        case GET_REQUESTS:
            [AsyncNotifier notifyWithName:REQUESTS_UPDATED object:nil userInfo:response];
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
            NSMutableDictionary *translated = [self translateContact:contact];
            if (translated != nil) {
                [_contactDatabase addContact:translated];
            }
            [AsyncNotifier notifyWithName:REQUEST_ACKNOWLEDGED object:nil userInfo:response];
        }
            break;
    }

}

- (NSMutableDictionary*)getContact:(NSString *)publicId {

    return contactMap[publicId];

}

- (void)loadContactList {

    if (contactList == nil) {
        contactList = [[_contactDatabase getContactList] mutableCopy];
        [self mapContacts];
    }

}

- (NSMutableDictionary*)getContactById:(NSInteger)contactId {

    [self loadContactList];
    for (NSMutableDictionary *contact in contactList) {
        if ([contact[@"contactId"] integerValue] == contactId) {
            return contact;
        }
    }
    return nil;

}

- (NSArray*)getContactList {

    [self loadContactList];
    return contactList;

}

- (NSArray*)getContacts:(NSString *)status {
    
    NSMutableArray *filtered = [NSMutableArray array];
    for (NSDictionary *contact in contactList) {
        NSString *currentStatus = contact[@"status"];
        if ([status isEqualToString:currentStatus]) {
            // Make the contact immutable
            [filtered addObject:[NSDictionary dictionaryWithDictionary:contact]];
        }
    }
    return filtered;
    
}

- (void)getRequests {

    NSMutableDictionary *request = [NSMutableDictionary dictionary];
    request[@"method"] = @"GetPendingRequests";
    [self sendRequest:request with:GET_REQUESTS];
    
}

- (void)mapContacts {

    [contactMap removeAllObjects];
    for (NSDictionary *contact in contactList) {
        contactMap[contact[@"publicId"]] = contact;
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
- (NSArray*)searchContacts:(NSString *)fragment {

    NSMutableArray *results = [NSMutableArray array];
    for (NSDictionary *contact in contactList) {
        NSString *nickname = [contact[@"nickname"] uppercaseString];
        NSString *publicId = [contact[@"publicId"] uppercaseString];
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

- (void)sendAlert:(NSString*)title with:(NSString*)message {

    NSMutableDictionary *info = [NSMutableDictionary dictionary];
    info[@"title"] = title;
    info[@"message"] = message;
    [[NSNotificationCenter defaultCenter] postNotificationName:PRESENT_ALERT object:nil userInfo:info];

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
/*
- (void)setResponseConsumer:(id<ResponseConsumer>)consumer {

    _responseConsumer = consumer;
    errorDelegate = _responseConsumer.errorDelegate;

}
*/
- (void)syncContacts {

    NSMutableDictionary *request = [NSMutableDictionary dictionary];
    NSArray *contactList = [_contactDatabase getContactList];
    NSMutableArray *syncList = [NSMutableArray array];
    for (NSDictionary *contact in contactList) {
        NSMutableDictionary *sync = [NSMutableDictionary dictionary];
        sync[@"publicId"] = contact[@"publicId"];
        sync[@"status"] = contact[@"status"];
        sync[@"currentSequence"] = contact[@"currentSequence"];
        sync[@"currentIndex"] = contact[@"currentIndex"];
        sync[@"timestamp"] = contact[@"timestamp"];
        [syncList addObject:sync];
    }
    request[@"method"] = @"SyncContacts";
    request[@"contacts"] = syncList;
    [self sendRequest:request with:SYNC_CONTACTS];

}

- (NSMutableDictionary*)translateContact:(NSDictionary*)serverContact {

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
        NSMutableDictionary *entity = [NSMutableDictionary dictionary];
        entity[@"publicId"] = publicId;
        if (acknowledgedNickname != nil) {
            entity[@"nickname"] = acknowledgedNickname;
        }
        entity[@"currentIndex"] = [NSNumber numberWithLongLong:0];
        entity[@"currentSequence"] = [NSNumber numberWithLongLong:0];
        entity[@"timestamp"] = serverContact[@"timestamp"];
        entity[@"status"] = status;
        NSData *adBytes = [[NSData alloc] initWithBase64EncodedString:authData options:0];
        NSData *nonceBytes = [[NSData alloc] initWithBase64EncodedString:nonce options:0];
        if (adBytes != nil && nonceBytes != nil) {
            entity[@"authData"] = adBytes;
            entity[@"nonce"] = nonceBytes;
            NSArray *keys = [self decodeKeys:keyStrings];
            if (keys != nil) {
                entity[@"messageKeys"] = keys;
                return entity;
            }
        }
        else {
            NSLog(@"Encoding error in translate contact");
        }
    }
    return nil;

}

- (void)updateContacts:(NSArray*)contacts {
    
    NSMutableArray *updates = [NSMutableArray array];
    for (NSDictionary *contact in contacts) {
        NSString *publicId = contact[@"publicId"];
        NSMutableDictionary *update = contactMap[publicId];
        if (update == nil) {
            // Something really wrong here
            NSLog(@"Process contact, contact %@ does not exist", publicId);
        }
        else {
            NSString *status = contact[@"status"];
            update[@"status"] = status;
            update[@"timestamp"] = contact[@"timestamp"];
            if ([status isEqualToString:@"accepted"]) {
                update[@"currentSequence"] = [NSNumber numberWithLong:0L];
                update[@"currentIndex"] = [NSNumber numberWithLong:0L];
                NSData *authData = [[NSData alloc] initWithBase64EncodedString:contact[@"authData"] options:0];
                update[@"authData"] = authData;
                NSData *nonce = [[NSData alloc] initWithBase64EncodedString:contact[@"nonce"] options:0];
                update[@"nonce"] = nonce;
                NSArray *messageKeys = contact[@"messageKeys"];
                NSMutableArray *keys = [NSMutableArray array];
                for (NSString *keyString in messageKeys) {
                    NSData *key = [[NSData alloc] initWithBase64EncodedString:keyString options:0];
                    [keys addObject:key];
                }
                update[@"messageKeys"] = keys;
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
    for (NSDictionary *entity in filtered) {
        [pending addObject:entity[@"publicId"]];
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

// Error delegate

- (void)postMethodError:(NSString *)_ {
    
    [self sendAlert:@"Contact Server Error" with:_];
    
}

- (void)getMethodError:(NSString *)_ {
    
    [self sendAlert:@"Contact Server Error" with:_];
    
}

- (void)sessionError:(NSString *)_ {
    
    [self sendAlert:@"Contact Server Error" with:_];
    
}

- (void)responseError:(NSString *)_ {
    
    [self sendAlert:@"Contact Error" with:_];
    
}

@end
