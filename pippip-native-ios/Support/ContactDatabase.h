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

- (void)addContact:(Contact*_Nonnull)contact;

- (void)addContactRequests:(NSArray<NSDictionary*>*_Nonnull)request;

- (BOOL)deleteContact:(NSInteger)contactId;

- (BOOL)deleteContactRequest:(NSString*_Nonnull)publicId;

- (NSArray<Contact*>*_Nonnull)getContactList;

- (NSArray<NSDictionary<NSString*, NSString*>*>*_Nonnull)getContactRequests;

- (void)updateContacts:(NSArray<Contact*>*_Nonnull)contacts;

@end
