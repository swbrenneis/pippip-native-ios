//
//  ContactManager.m
//  pippip-native-ios
//
//  Created by Steve Brenneis on 12/12/17.
//  Copyright © 2017 seComm. All rights reserved.
//

#import "ContactManager.h"

@interface ContactManager ()
{

    NSArray<ContactEntity*> *entities;

}

@property (weak, nonatomic) AccountManager *accountManager;

@end

@implementation ContactManager

- (instancetype)initWithAccountManager:(AccountManager *)manager {
    self = [super init];

    _accountManager = manager;
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

@end
