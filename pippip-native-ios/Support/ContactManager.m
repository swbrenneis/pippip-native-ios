//
//  ContactManager.m
//  pippip-native-ios
//
//  Created by Steve Brenneis on 12/12/17.
//  Copyright © 2017 seComm. All rights reserved.
//

#import "ContactManager.h"
#import "RESTSession.h"
#import "EnclaveRequest.h"
#import "EnclaveResponse.h"
#import "SessionState.h"
#import "AlertErrorDelegate.h"
#import "ContactDatabase.h"
#import "NSData+HexEncode.h"
#import "CKGCMCodec.h"

typedef enum REQUEST { SET_NICKNAME, REQUEST_CONTACT } ContactRequest;

@interface ContactManager ()
{
    ContactDatabase *contactDatabase;
    ContactRequest contactRequest;
}

//@property (weak, nonatomic) AccountManager *accountManager;
@property (weak, nonatomic) UIViewController *viewController;
@property (weak, nonatomic) id<ResponseConsumer> responseConsumer;
@property (weak, nonatomic) SessionState *sessionState;
@property (weak, nonatomic) RESTSession *session;

@end

@implementation ContactManager

@synthesize errorDelegate;
@synthesize postPacket;

- (instancetype)initWithRESTSession:(RESTSession *)restSession {
    self = [super init];

    _session = restSession;
    contactDatabase = nil;

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
/*
- (void)addLocalContact:(NSMutableDictionary *)entity {

    [contactDatabase addContact:entity];

}
*/
- (void)createNickname:(NSString *)nickname withOldNickname:(NSString *)oldNickname {
    
    NSMutableDictionary *request = [NSMutableDictionary dictionary];
    request[@"method"] = @"SetNickname";
    if (nickname != nil) {
        request[@"newNickname"] = nickname;
    }
    if (oldNickname != nil) {
        request[@"oldNickname"] = oldNickname;
    }
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
/*
- (void)deleteLocalContact:(NSString *)publicId {

    [contactDatabase deleteContact:publicId];

}

- (NSArray*)getContacts:(NSString *)status {
    
    NSMutableArray *filtered = [NSMutableArray array];
    for (NSDictionary *contact in contactDatabase.indexed) {
        NSString *currentStatus = contact[@"status"];
        if ([status isEqualToString:currentStatus]) {
            // Make the contact immutable
            [filtered addObject:[NSDictionary dictionaryWithDictionary:contact]];
        }
    }
    return filtered;
    
}
*/
- (void)getNickname:(NSString *)publicId {

    NSMutableDictionary *request = [NSMutableDictionary dictionary];
    request[@"method"] = @"GetNickname";
    request[@"publicId"] = publicId;
    [self sendRequest:request];
    
}
/*
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
*/
- (void)matchNickname:(NSString *)nickname {
    
    NSMutableDictionary *request = [NSMutableDictionary dictionary];
    request[@"method"] = @"MatchNickname";
    request[@"nickname"] = nickname;
    [self sendRequest:request];
    
}

- (void)postComplete:(NSDictionary*)response {

    if (response != nil) {
        EnclaveResponse *enclaveResponse = [[EnclaveResponse alloc] initWithState:_sessionState];
        if ([enclaveResponse processResponse:response errorDelegate:errorDelegate]) {
            NSDictionary *contactResponse = [enclaveResponse getResponse];
            if (contactResponse != nil && _responseConsumer != nil) {
                [_responseConsumer response:contactResponse];
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

- (NSArray*)searchContacts:(NSString *)fragment {

    NSString *search = [fragment uppercaseString];
    NSMutableArray *results = [NSMutableArray array];
    NSArray *indexed = [contactDatabase getContactList];
    for (NSDictionary *contact in indexed) {
        NSString *nickname = contact[@"nickname"];
        NSString *publicId = contact[@"publicId"];
        if ([[publicId uppercaseString] containsString:search]) {
            [results addObject:contact];
        }
        else if (nickname != nil) {
            if ([[nickname uppercaseString] containsString:search]) {
                [results addObject:contact];
            }
        }
    }
    
    return results;

}

- (void)sendRequest:(NSDictionary*)request {
    
    EnclaveRequest *enclaveRequest = [[EnclaveRequest alloc] initWithState:_sessionState];
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
/*
- (void)setContacts:(NSArray*)newContacts {

    [contactDatabase syncContacts:newContacts];

}

- (void)setNickname:(NSString *)nickname withPublicId:(NSString *)publicId {

    NSDictionary *contact = contactDatabase.keyed[publicId];
    if (contact == nil) {
        NSLog(@"Set nickname, contact %@ not found", publicId);
    }
    else {
        NSMutableDictionary *update = [contact mutableCopy];
        update[@"nickname"] = nickname;
        [contactDatabase updateContact:update];
    }

}
*/
- (void)setResponseConsumer:(id<ResponseConsumer>)consumer {
    _responseConsumer = consumer;
}

- (void)setSessionState:(SessionState *)state {
    _sessionState = state;
}

- (void)setViewController:(UIViewController *)controller {

    _viewController = controller;
    errorDelegate = [[AlertErrorDelegate alloc] initWithViewController:_viewController
                                                             withTitle:@"Contact Error"];

}
/*
- (void)syncContacts {
    
    NSMutableDictionary *request = [NSMutableDictionary dictionary];
    request[@"method"] = @"GetAllContacts";
    [self sendRequest:request];

}

- (void)updateContact:(NSMutableDictionary*)contact {

    [contactDatabase updateContact:contact];

}
*/
@end
