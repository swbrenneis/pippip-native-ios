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
#import "NSData+HexEncode.h"
#import "CKGCMCodec.h"

typedef enum REQUEST { SET_NICKNAME, REQUEST_CONTACT } ContactRequest;

@interface ContactManager ()
{

    NSArray<ContactEntity*> *entities;
    RESTSession *session;
    ContactRequest contactRequest;
    NSString *pendingNickname;
    id<ResponseConsumer> responseConsumer;

}

@property (weak, nonatomic) AccountManager *accountManager;
@property (weak, nonatomic) UIViewController *viewController;

@end

@implementation ContactManager

@synthesize errorDelegate;
@synthesize postPacket;

- (instancetype)initWithAccountManager:(AccountManager *)manager {
    self = [super init];

    _accountManager = manager;
    session = [[RESTSession alloc] init];
    session.requestProcess = self;
    return self;

}

- (NSInteger) count {

    return 0;

}

- (NSString*)currentNickname {

    return _accountManager.config[@"nickname"];

}

- (void)checkNickname:(NSString *)nickname {
    
    NSMutableDictionary *request = [NSMutableDictionary dictionary];
    request[@"method"] = @"CheckNickname";
    request[@"nickname"] = nickname;
    [self sendRequest:request];

}

- (ContactEntity*) entityAtIndex:(NSInteger)index {

    if (index >= entities.count) {
        return nil;
    }
    else {
        return entities[index];
    }

}

- (void)postComplete:(NSDictionary*)response {

    if (response != nil) {
        EnclaveResponse *enclaveResponse = [[EnclaveResponse alloc] initWithState:_accountManager.sessionState];
        [enclaveResponse processResponse:response errorDelegate:errorDelegate];
        NSDictionary *contactResponse = [enclaveResponse getResponse];
        if (contactResponse != nil) {
            NSString *method = contactResponse[@"method"];
            NSDictionary *info = contactResponse[@"response"];
            if (responseConsumer != nil) {
                [responseConsumer response:info withMethod:method];
            }
        }
    }

}

- (void)requestContact:(ContactEntity*)entity {
    
    EnclaveRequest *request = [[EnclaveRequest alloc] initWithState:_accountManager.sessionState];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    dict[@"request"] = @"RequestContact";
    dict[@"publicId"] = entity.publicId;
    if (entity.nickname != nil) {
        dict[@"nickname"] = entity.nickname;
    }
    postPacket = request;
    [session doPost];

}

- (void)sessionComplete:(NSDictionary*)response {
    // Nothing to do here. Session is already established.
}

- (void)sendRequest:(NSDictionary*)request {
    
    EnclaveRequest *enclaveRequest = [[EnclaveRequest alloc] initWithState:_accountManager.sessionState];
    [enclaveRequest setRequest:request];

    postPacket = enclaveRequest;
    [session doPost];
    
}

- (void)setNickname:(NSString *)nickname {

    pendingNickname = nickname;
    NSMutableDictionary *request = [NSMutableDictionary dictionary];
    request[@"method"] = @"SetNickname";
    request[@"newNickname"] = nickname;
    NSString *oldNickname = _accountManager.config[@"nickname"];
    if (oldNickname != nil) {
        request[@"oldNickname"] = oldNickname;
    }
    [self sendRequest:request];

}

- (void)setResponseConsumer:(id<ResponseConsumer>)consumer {
    responseConsumer = consumer;
}

- (void)setViewController:(UIViewController *)controller {

    _viewController = controller;
    errorDelegate = [[AlertErrorDelegate alloc] initWithViewController:_viewController
                                                             withTitle:@"Contact Error"];

}

@end
