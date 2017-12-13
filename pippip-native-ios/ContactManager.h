//
//  ContactManager.h
//  pippip-native-ios
//
//  Created by Steve Brenneis on 12/12/17.
//  Copyright © 2017 seComm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AccountManager.h"
#import "ContactEntity.h"

@interface ContactManager : NSObject

- (instancetype) initWithAccountManager:(AccountManager*)manager;

- (NSInteger) count;

- (ContactEntity*) entityAtIndex:(NSInteger)index;

- (void) requestContact:(ContactEntity*)entity;

@end
