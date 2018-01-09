//
//  ContactDatabase.h
//  pippip-native-ios
//
//  Created by Steve Brenneis on 1/7/18.
//  Copyright © 2018 seComm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AccountManager.h"

@interface ContactDatabase : NSObject

- (instancetype)initWithAccountManager:(AccountManager*)manager;

- (NSInteger)contactCount;

- (void)loadContacts;

- (void)addContact:(NSMutableDictionary*)contact withId:(NSString*)publicId;

- (void)deleteContact:(NSString*)publicId;

- (NSMutableDictionary*)getContact:(NSString*)publicId;

- (NSMutableDictionary*)getContactByIndex:(NSInteger)index;

- (void)storeContacts;

@end
