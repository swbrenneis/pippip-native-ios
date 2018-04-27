//
//  ContactDatabase.h
//  pippip-native-ios
//
//  Created by Steve Brenneis on 1/7/18.
//  Copyright © 2018 seComm. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Contact;

@interface ContactDatabase : NSObject

- (void)addContact:(Contact*)contact;

- (BOOL)deleteContact:(NSInteger)contactId;

- (NSArray<Contact*>*)getContactList;

- (void)updateContacts:(NSArray<Contact*>*)contacts;

@end
