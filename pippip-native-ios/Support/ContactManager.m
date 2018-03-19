//
//  ContactManager.m
//  pippip-native-ios
//
//  Created by Steve Brenneis on 12/12/17.
//  Copyright © 2017 seComm. All rights reserved.
//

#import "ContactManager.h"
#import "ApplicationSingleton.h"
#import "RESTSession.h"
#import "EnclaveRequest.h"
#import "EnclaveResponse.h"
#import "ContactDatabase.h"
//#import "NSData+HexEncode.h"
#import "CKGCMCodec.h"

typedef enum REQUEST { SET_NICKNAME, REQUEST_CONTACT } ContactRequest;

@interface ContactManager ()
{
    ContactDatabase *contactDatabase;
    ContactRequest contactRequest;
    NSArray *contactList;
}

//@property (weak, nonatomic) UIViewController *viewController;
@property (weak, nonatomic) id<ResponseConsumer> responseConsumer;
//@property (weak, nonatomic) SessionState *sessionState;
@property (weak, nonatomic) RESTSession *session;

@end

@implementation ContactManager

@synthesize errorDelegate;
@synthesize postPacket;

- (instancetype)init {
    self = [super init];

    _session = nil;
    contactDatabase = [[ContactDatabase alloc] init];

//    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(newSession:) name:@"NewSession" object:nil];

    return self;

}

- (void)acknowledgeRequest:(NSString *)response withId:(NSString *)publicId{

    NSMutableDictionary *request = [NSMutableDictionary dictionary];
    request[@"method"] = @"AcknowledgeRequest";
    request[@"id"] = publicId;
    request[@"response"] = response;
    [self sendRequest:request];
    
}

- (void)addFriend:(NSString *)publicId {
    
    NSMutableDictionary *request = [NSMutableDictionary dictionary];
    request[@"method"] = @"UpdateWhitelist";
    request[@"action"] = @"add";
    request[@"id"] = publicId;
    [self sendRequest:request];
    
}

- (void)deleteContact:(NSString *)publicId {

    NSMutableDictionary *request = [NSMutableDictionary dictionary];
    request[@"method"] = @"DeleteContact";
    request[@"publicId"] = publicId;
    [self sendRequest:request];
    
}

- (void)deleteFriend:(NSString *)publicId {
    
    NSMutableDictionary *request = [NSMutableDictionary dictionary];
    request[@"method"] = @"UpdateWhitelist";
    request[@"action"] = @"delete";
    request[@"id"] = publicId;
    [self sendRequest:request];
    
}

- (NSArray*)getContacts:(NSString *)status {
    
    NSMutableArray *filtered = [NSMutableArray array];
    if (contactList == nil) {
        contactList = [contactDatabase getContactList];
    }
    for (NSDictionary *contact in contactList) {
        NSString *currentStatus = contact[@"status"];
        if ([status isEqualToString:currentStatus]) {
            // Make the contact immutable
            [filtered addObject:[NSDictionary dictionaryWithDictionary:contact]];
        }
    }
    return filtered;
    
}

- (NSArray*)getPendingContactIds {

    NSMutableArray *pending = [NSMutableArray array];
    NSArray *filtered = [self getContacts:@"pending"];
    for (NSDictionary *entity in filtered) {
        [pending addObject:entity[@"publicId"]];
    }
    return pending;

}

- (void)getRequests {

    NSMutableDictionary *request = [NSMutableDictionary dictionary];
    request[@"method"] = @"GetPendingRequests";
    [self sendRequest:request];
    
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
    [self sendRequest:request];
    
}
/*
- (void)newSession:(NSNotification*)notification {

    _sessionState = (SessionState*)notification.object;

}
*/
- (void)postComplete:(NSDictionary*)response {

    if (response != nil) {
        EnclaveResponse *enclaveResponse = [[EnclaveResponse alloc] init];
        if ([enclaveResponse processResponse:response errorDelegate:errorDelegate]) {
            NSDictionary *contactResponse = [enclaveResponse getResponse];
            if (_responseConsumer != nil) {
                [_responseConsumer response:contactResponse];
            }
            else {
                NSLog(@"ContactManager.postComplete - response consumer is nil");
            }
        }
    }

}

- (void)requestContact:(NSString*)publicId {

    NSMutableDictionary *request = [NSMutableDictionary dictionary];
    request[@"method"] = @"RequestContact";
    request[@"id"] = publicId;
    [self sendRequest:request];
    
}

/*
 * fragment should be upper case
 */
- (NSArray*)searchContacts:(NSString *)fragment {

    NSMutableArray *results = [NSMutableArray array];
    if (contactList == nil) {
        contactList = [contactDatabase getContactList];
    }
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

- (void)sendRequest:(NSDictionary*)request {

    if (_session == nil) {
        ApplicationSingleton *app = [ApplicationSingleton instance];
        _session = app.restSession;
    }

    EnclaveRequest *enclaveRequest = [[EnclaveRequest alloc] init];
    [enclaveRequest setRequest:request];

    postPacket = enclaveRequest;
    [_session queuePost:self];
    
}

- (void)sessionComplete:(NSDictionary*)response {
    // Nothing to do here. Session is already established.
}

- (void)setContactPolicy:(NSString*)policy {

    NSMutableDictionary *request = [NSMutableDictionary dictionary];
    request[@"method"] = @"SetContactPolicy";
    request[@"policy"] = policy;
    [self sendRequest:request];

}

- (void)setResponseConsumer:(id<ResponseConsumer>)consumer {

    _responseConsumer = consumer;
    errorDelegate = _responseConsumer.errorDelegate;

}

- (void)syncContacts {

    NSMutableDictionary *request = [NSMutableDictionary dictionary];
    NSArray *contactList = [contactDatabase getContactList];
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
    [self sendRequest:request];

}

- (void)updateContact:(NSDictionary*)contact {
    
    NSString *publicId = contact[@"publicId"];
    NSDictionary *entity = [contactDatabase getContact:publicId];
    if (entity == nil) {
        // Something really wrong here
        NSLog(@"Process contact, contact %@ does not exist", publicId);
    }
    else {
        NSMutableDictionary *update = [entity mutableCopy];
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
        [contactDatabase updateContact:update];
    }
    
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
    [self sendRequest:request];
    
}

- (NSUInteger)updatePendingContacts {

     NSArray *pending = [self getPendingContactIds];
     if (pending.count > 0) {
         NSLog(@"%@", @"Updating pending contacts");
         NSMutableDictionary *request = [NSMutableDictionary dictionary];
         request[@"method"] = @"UpdatePendingContacts";
         request[@"pending"] = pending;
         [self sendRequest:request];
     }
    return pending.count;

}

@end
