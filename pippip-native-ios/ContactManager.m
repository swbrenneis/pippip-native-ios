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
#import "SessionState.h"
#import "AlertErrorDelegate.h"

@interface ContactManager ()
{

    NSArray<ContactEntity*> *entities;
    RESTSession *session;

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

- (ContactEntity*) entityAtIndex:(NSInteger)index {

    if (index >= entities.count) {
        return nil;
    }
    else {
        return entities[index];
    }

}

- (void) requestContact:(ContactEntity *)entity {

    
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

- (void)setViewController:(UIViewController *)controller {

    _viewController = controller;
    errorDelegate = [[AlertErrorDelegate alloc] initWithViewController:_viewController
                                                             withTitle:@"Contact Error"];

}

- (void)postComplete:(NSDictionary*)response {
    
}

@end
