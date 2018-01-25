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
    RESTSession *session;
    ContactRequest contactRequest;

}

@property (weak, nonatomic) AccountManager *accountManager;
@property (weak, nonatomic) UIViewController *viewController;
@property (weak, nonatomic) id<ResponseConsumer> responseConsumer;

@end

@implementation ContactManager

@synthesize errorDelegate;
@synthesize postPacket;

- (instancetype)initWithAccountManager:(AccountManager *)manager {
    self = [super init];

    _accountManager = manager;
    contacts = [[ContactDatabase alloc] initWithAccountManager:manager];
    session = [[RESTSession alloc] init];
    session.requestProcess = self;
    return self;

}

- (void)acknowledgeRequest:(NSString *)response withId:(NSString *)publicId{

    NSMutableDictionary *request = [NSMutableDictionary dictionary];
    request[@"method"] = @"AcknowledgeRequest";
    request[@"id"] = publicId;
    request[@"response"] = response;
    [self sendRequest:request];
    
}

- (void)addContact:(NSMutableDictionary *)entity {

    NSString *publicId = entity[@"publicId"];
    [contacts addContact:entity withId:publicId];
    [contacts storeContacts];

}

- (void)addFriend:(NSString *)publicId {

    NSMutableDictionary *request = [NSMutableDictionary dictionary];
    request[@"method"] = @"UpdateWhitelist";
    request[@"action"] = @"add";
    request[@"id"] = publicId;
    [self sendRequest:request];
    
}

- (NSInteger) contactCount {

    return [contacts contactCount];

}

- (NSDictionary*)contactAtIndex:(NSInteger)index {

    return [contacts getContactByIndex:index];

}

- (void)createNickname:(NSString *)nickname {
    
    NSMutableDictionary *request = [NSMutableDictionary dictionary];
    request[@"method"] = @"SetNickname";
    if (nickname != nil) {
        request[@"newNickname"] = nickname;
    }
    NSString *oldNickname = [_accountManager getConfigItem:@"nickname"];
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
    [contacts storeContacts];

}

- (NSMutableDictionary*)getContact:(NSString *)publicId {

    return [contacts getContact:publicId];

}

- (void)getNickname:(NSString *)publicId {

    NSMutableDictionary *request = [NSMutableDictionary dictionary];
    request[@"method"] = @"GetNickname";
    request[@"publicId"] = publicId;
    [self sendRequest:request];
    
}

- (void)getRequests {

    NSMutableDictionary *request = [NSMutableDictionary dictionary];
    request[@"method"] = @"GetPendingRequests";
    [self sendRequest:request];
    
}

- (void)loadContacts {

    [contacts loadContacts];

}

- (void)matchNickname:(NSString *)nickname {
    
    NSMutableDictionary *request = [NSMutableDictionary dictionary];
    request[@"method"] = @"MatchNickname";
    request[@"nickname"] = nickname;
    [self sendRequest:request];
    
}

- (void)postComplete:(NSDictionary*)response {

    if (response != nil) {
        EnclaveResponse *enclaveResponse = [[EnclaveResponse alloc] initWithState:_accountManager.sessionState];
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
    
    EnclaveRequest *enclaveRequest = [[EnclaveRequest alloc] initWithState:_accountManager.sessionState];
    [enclaveRequest setRequest:request];

    postPacket = enclaveRequest;
    [session doPost];
    
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

- (void)setContacts:(NSMutableArray *)newContacts {

    [contacts syncContacts:newContacts];
    [contacts storeContacts];

}

- (void)setNickname:(NSString *)nickname withPublicId:(NSString *)publicId {

    NSMutableDictionary *entity = [contacts getContact:publicId];
    entity[@"nickname"] = nickname;
    [contacts storeContacts];

}

- (void)setResponseConsumer:(id<ResponseConsumer>)consumer {
    _responseConsumer = consumer;
}

- (void)setViewController:(UIViewController *)controller {

    _viewController = controller;
    errorDelegate = [[AlertErrorDelegate alloc] initWithViewController:_viewController
                                                             withTitle:@"Contact Error"];

}

- (void)storeContacts {

    [contacts storeContacts];

}

- (void)syncContacts {
    
    NSMutableDictionary *request = [NSMutableDictionary dictionary];
    request[@"method"] = @"GetAllContacts";
    [self sendRequest:request];

}

@end
