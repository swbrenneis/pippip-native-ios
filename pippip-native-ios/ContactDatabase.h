//
//  ContactDatabase.h
//  pippip-native-ios
//
//  Created by Steve Brenneis on 1/7/18.
//  Copyright © 2018 seComm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SessionState.h"

@interface ContactDatabase : NSObject

- (NSInteger)contactCount;

- (void)loadContacts:(SessionState*)state;

- (void)addContact:(NSMutableDictionary*)contact withId:(NSString*)publicId;

- (void)deleteContact:(NSString*)publicId;

- (NSMutableDictionary*)getContact:(NSString*)publicId;

- (NSMutableDictionary*)getContactByIndex:(NSInteger)index;

- (NSArray*)getContacts:(NSString*)status;

- (void)storeContacts:(NSString*)accountName;

- (void)syncContacts:(NSMutableArray*)synched;

@end
