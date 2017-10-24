//
//  AccountRequestStep.m
//  pippip-native-ios
//
//  Created by Steve Brenneis on 10/20/17.
//  Copyright © 2017 seComm. All rights reserved.
//

#import "AccountRequestStep.h"
#import "NewAccountRequest.h"
#import "NewAccountResponse.h"
#import "AlertErrorDelegate.h"

@interface AccountRequestStep ()
{
    //SessionState *state;
    //NewAccountRequest *request;
}

@end

@implementation AccountRequestStep

- (instancetype)initWithState:(SessionState *)sessionState withViewController:(UIViewController *)viewController {
    self = [super init];

    //state = sessionState;
    _postPacket = [[NewAccountRequest alloc] initWithState:sessionState];
    _response = [[NewAccountResponse alloc] initWithState:sessionState];
    _errorDelegate = [[AlertErrorDelegate alloc] initWithViewController:viewController
                                                              withTitle:@"Account Request Error"];
    return self;

}

- (void)step:(RESTSession*)session {

    [session doPost];

}


@end
