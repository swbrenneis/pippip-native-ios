//
//  ContactManager.h
//  pippip-native-ios
//
//  Created by Steve Brenneis on 12/12/17.
//  Copyright © 2017 seComm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RESTSession.h"
#import "ContactDatabase.h"

@class SessionState;
@class Contact;
@protocol ResponseConsumer;

@interface ContactManager : NSObject <RequestProcessProtocol>

- (void)acknowledgeRequest:(NSString*_Nonnull)response
                    withId:(NSString*_Nonnull)publicId
              withNickname:(NSString*_Nullable)nickname;

- (BOOL)addFriend:(NSString*_Nonnull)publicId;

- (void)deleteContact:(NSString*_Nonnull)publicId;

- (void)deleteFriend:(NSString*_Nonnull)publicId;

- (Contact*_Nullable)getContact:(NSString*_Nullable)publicId;

- (Contact*_Nullable)getContactById:(NSInteger)contactId;

- (NSString*_Nullable)getContactPublicId:(NSString*_Nonnull)nickname;

- (NSArray<Contact*>*_Nonnull)getContactList;

- (void)getRequests;

- (void)loadContactList;

- (void)matchNickname:( NSString* _Nullable )nickname withPublicId:( NSString* _Nullable )publicId;

- (void)requestContact:(NSString*_Nonnull)publicId withNickname:(NSString*_Nullable)nickname;

- (NSArray<Contact*>*_Nonnull)searchContacts:(NSString*_Nonnull)fragment;

- (void)setContactPolicy:(NSString*_Nonnull)policy;

- (void)syncContacts;

- (void)updateContact:(Contact*_Nonnull)contact;

- (void)updateContacts:(NSArray<NSDictionary*>*_Nonnull)serverContacts;

- (void)updateNickname:(NSString*_Nullable)nickname withOldNickname:(NSString*_Nullable)oldNickname;

- (NSUInteger)updatePendingContacts;

@end
