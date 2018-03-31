//
//  ContactManager.h
//  pippip-native-ios
//
//  Created by Steve Brenneis on 12/12/17.
//  Copyright © 2017 seComm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RequestProcess.h"
#import "RESTSession.h"
#import "ContactDatabase.h"

@class SessionState;
@protocol ResponseConsumer;

@interface ContactManager : NSObject <RequestProcess, ErrorDelegate>

- (void)acknowledgeRequest:(NSString*_Nonnull)response
                    withId:(NSString*_Nonnull)publicId
              withNickname:(NSString*_Nullable)nickname;

- (BOOL)addFriend:(NSString*_Nonnull)publicId;

- (void)deleteContact:(NSString*_Nonnull)publicId;

- (void)deleteFriend:(NSString*_Nonnull)publicId;

- (NSMutableDictionary*_Nullable)getContact:(NSString*_Nullable)publicId;

- (NSMutableDictionary*_Nullable)getContactById:(NSInteger)contactId;

- (NSArray<NSDictionary*>*_Nonnull)getContactList;

- (void)getRequests;

- (void)matchNickname:( NSString* _Nullable )nickname withPublicId:( NSString* _Nullable )publicId;

- (void)requestContact:(NSString*_Nonnull)publicId withNickname:(NSString*_Nullable)nickname;

- (NSArray*_Nonnull)searchContacts:(NSString*_Nonnull)fragment;

- (void)setContactPolicy:(NSString*_Nonnull)policy;

- (void)syncContacts;

- (void)updateContacts:(NSArray*_Nonnull)contacts;

- (void)updateNickname:(NSString*_Nullable)nickname withOldNickname:(NSString*_Nullable)oldNickname;

- (NSUInteger)updatePendingContacts;

@end
