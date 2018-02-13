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
#import "ResponseConsumer.h"
#import "SessionState.h"

@interface ContactManager : NSObject <RequestProcess>

- (instancetype)initWithRESTSession:(RESTSession*)restSession;

- (void)acknowledgeRequest:(NSString*)response withId:(NSString*)publicId;
/*
- (void)addLocalContact:(NSMutableDictionary*)entity;
*/
- (void)addFriend:(NSString*)publicId;
/*
- (NSInteger)contactCount;
*/
- (void)createNickname:(NSString*)nickname withOldNickname:(NSString*)oldNickname;

- (void)deleteContact:(NSString*)publicId;

- (void)deleteFriend:(NSString*)publicId;
/*
- (void)deleteLocalContact:(NSString*)publicId;

- (void)endSession;

- (NSDictionary*)contactAtIndex:(NSInteger)index;

- (NSMutableDictionary*)getContact:(NSString*)publicId;

- (NSMutableDictionary*)getContactById:(NSInteger)contactId;
*/
- (void)getNickname:(NSString*)publicId;

- (NSArray*)getPendingContactIds;

- (void)getRequests;
/*
- (BOOL)loadContacts;
*/
- (void)matchNickname:(NSString*)nickname;

- (void)requestContact:(NSString*)publicId;

- (NSArray*)searchContacts:(NSString*)fragment;

- (void)setContactPolicy:(NSString*)policy;
/*
- (void)setContacts:(NSMutableArray*)contacts;

- (void)setNickname:(NSString*)nickname withPublicId:(NSString*)publicId;
*/
- (void)setResponseConsumer:(id<ResponseConsumer>)consumer;

- (void)setSessionState:(SessionState*)state;

- (void)setViewController:(UIViewController*)controller;
/*
- (void)syncContacts;

- (void)updateContact:(NSMutableDictionary*)contact;
*/
@end
