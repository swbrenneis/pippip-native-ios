//
//  AccountFinishStep.m
//  pippip-native-ios
//
//  Created by Steve Brenneis on 10/25/17.
//  Copyright © 2017 seComm. All rights reserved.
//

#import "AccountFinishStep.h"
#import "NewAccountFinish.h"
#import "NewAccountFinal.h"
#import "AlertErrorDelegate.h"

@implementation AccountFinishStep

- (instancetype)initWithState:(SessionState *)sessionState withViewController:(UIViewController *)viewController {
    self = [super init];
    
    //state = sessionState;
    _postPacket = [[NewAccountFinish alloc] initWithState:sessionState];
    _response = [[NewAccountFinal alloc] initWithState:sessionState];
    _errorDelegate = [[AlertErrorDelegate alloc] initWithViewController:viewController
                                                              withTitle:@"Account Finish Error"];
    return self;
    
}

- (void)step:(RESTSession*)session {
    
    [session doPost];
    
}


@end
