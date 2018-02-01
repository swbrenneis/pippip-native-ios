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

- (void)addLocalContact:(NSMutableDictionary*)entity;

- (void)addFriend:(NSString*)publicId;

- (void)addNewMessages:(NSArray*)messages;

- (NSInteger)contactCount;

- (void)contactsUpdated;

- (void)createNickname:(NSString*)nickname withOldNickname:(NSString*)oldNickname;

- (void)deleteContact:(NSString*)publicId;

- (void)deleteFriend:(NSString*)publicId;

- (void)deleteLocalContact:(NSString*)publicId;

- (NSDictionary*)contactAtIndex:(NSInteger)index;

- (NSMutableDictionary*)getContact:(NSString*)publicId;

- (NSArray*)getContactIds;

- (void)getNickname:(NSString*)publicId;

- (NSArray*)getPendingContacts;

- (void)getRequests;

- (void)loadContacts;

- (void)matchNickname:(NSString*)nickname;

- (void)setContactPolicy:(NSString*)policy;

- (void)setContacts:(NSMutableArray*)contacts;

- (void)setNickname:(NSString*)nickname withPublicId:(NSString*)publicId;

- (void)setResponseConsumer:(id<ResponseConsumer>)consumer;

- (void)setSessionState:(SessionState*)state;

- (void)setViewController:(UIViewController*)controller;

//- (void)storeContacts;

- (void)syncContacts;

- (void)requestContact:(NSString*)publicId;

@end
