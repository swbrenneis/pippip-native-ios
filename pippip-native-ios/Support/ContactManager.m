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
    ContactDatabase *contacts;
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
    contacts = [[ContactDatabase alloc] init];

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

- (void)addLocalContact:(NSMutableDictionary *)entity {

    [contacts addContact:entity];

}

- (void)addNewMessages:(NSArray *)messages {
    
}

- (NSInteger) contactCount {

    return [contacts contactCount];

}

- (NSDictionary*)contactAtIndex:(NSInteger)index {

    return [contacts getContactByIndex:index];

}

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

- (void)deleteLocalContact:(NSString *)publicId {

    [contacts deleteContact:publicId];

}

- (void)endSession {

}

- (NSDictionary*)getContact:(NSString *)publicId {

    return [contacts getContactById:publicId];

}

- (void)getNickname:(NSString *)publicId {

    NSMutableDictionary *request = [NSMutableDictionary dictionary];
    request[@"method"] = @"GetNickname";
    request[@"publicId"] = publicId;
    [self sendRequest:request];
    
}

- (NSArray*)getPendingContactIds {

    NSMutableArray *pending = [NSMutableArray array];
    NSArray *filtered = [contacts getContacts:@"pending"];
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

- (BOOL)loadContacts {

    return [contacts loadContacts:_sessionState];

}

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

- (void)setContacts:(NSArray*)newContacts {

    [contacts syncContacts:newContacts];

}

- (void)setNickname:(NSString *)nickname withPublicId:(NSString *)publicId {

    NSDictionary *contact = [contacts getContactById:publicId];
    if (contact == nil) {
        NSLog(@"Set nickname, contact %@ not found", publicId);
    }
    else {
        NSMutableDictionary *update = [contact mutableCopy];
        update[@"nickname"] = nickname;
        [contacts updateContact:update];
    }

}

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

- (void)syncContacts {
    
    NSMutableDictionary *request = [NSMutableDictionary dictionary];
    request[@"method"] = @"GetAllContacts";
    [self sendRequest:request];

}

- (void)updateContact:(NSMutableDictionary*)contact {

    [contacts updateContact:contact];

}

@end
