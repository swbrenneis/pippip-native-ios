//
//  ContactManager.h
//  pippip-native-ios
//
//  Created by Steve Brenneis on 12/12/17.
//  Copyright © 2017 seComm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RequestProcess.h"
#import "AccountManager.h"
#import "ResponseConsumer.h"

@interface ContactManager : NSObject <RequestProcess>

- (instancetype)initWithAccountManager:(AccountManager*)manager;

- (void)acknowledgeRequest:(NSString*)response withId:(NSString*)publicId;

- (void)addContact:(NSMutableDictionary*)entity;

- (void)addFriend:(NSString*)publicId;

- (NSInteger)contactCount;

- (void)createNickname:(NSString*)nickname;

- (void)deleteContact:(NSString*)publicId;

- (void)deleteFriend:(NSString*)publicId;

- (void)deleteLocalContact:(NSString*)publicId;

- (NSDictionary*)contactAtIndex:(NSInteger)index;

- (NSMutableDictionary*)getContact:(NSString*)publicId;

- (void)getNickname:(NSString*)publicId;

- (void)getRequests;

- (void)loadContacts;

- (void)matchNickname:(NSString*)nickname;

- (void)setContactPolicy:(NSString*)policy;

- (void)setContacts:(NSMutableArray*)contacts;

- (void)setNickname:(NSString*)nickname withPublicId:(NSString*)publicId;

- (void)setResponseConsumer:(id<ResponseConsumer>)consumer;

- (void)setViewController:(UIViewController*)controller;

- (void)storeContacts;

- (void)syncContacts;

- (void)requestContact:(NSString*)publicId;

@end
