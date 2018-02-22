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

- (void)acknowledgeRequest:(NSString*)response withId:(NSString*)publicId;

- (void)addFriend:(NSString*)publicId;

- (void)createNickname:(NSString*)nickname withOldNickname:(NSString*)oldNickname;

- (void)deleteContact:(NSString*)publicId;

- (void)deleteFriend:(NSString*)publicId;

- (void)getNickname:(NSString*)publicId;

//- (NSArray*)getPendingContactIds;

- (void)getRequests;

- (void)matchNickname:(NSString*)nickname;

- (void)requestContact:(NSString*)publicId;

- (NSArray*)searchContacts:(NSString*)fragment;

- (void)setContactPolicy:(NSString*)policy;

- (void)setResponseConsumer:(id<ResponseConsumer>)consumer;

//- (void)setViewController:(UIViewController*)controller;

- (void)startNewSession:(SessionState*)state;

- (void)syncContacts;

- (void)updateContact:(NSDictionary*)contact;

- (NSUInteger)updatePendingContacts;

@end
