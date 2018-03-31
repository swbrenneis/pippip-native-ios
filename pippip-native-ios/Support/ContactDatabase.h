//
//  ContactDatabase.h
//  pippip-native-ios
//
//  Created by Steve Brenneis on 1/7/18.
//  Copyright © 2018 seComm. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ContactDatabase : NSObject

- (NSInteger)addContact:(NSMutableDictionary*)contact;

- (void)deleteContacts:(NSArray*)contacts;

//- (NSMutableDictionary*)getContact:(NSString*)publicId;

//- (NSMutableDictionary*)getContactById:(NSInteger)contactId;

- (NSArray<NSDictionary*>*)getContactList;

- (void)updateContacts:(NSArray*)contacts;

@end
